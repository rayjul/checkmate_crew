window.stockfishBridge = (() => {
  let worker;
  let readyPromise;
  let busy = false;
  let activeSkillLevel;
  const cancelPending = new Set();

  function waitForReply(matches, timeoutMs = 10000) {
    return new Promise((resolve, reject) => {
      const cleanup = () => {
        clearTimeout(timer);
        worker.removeEventListener('message', onMessage);
        worker.removeEventListener('error', onError);
        cancelPending.delete(cancel);
      };

      const cancel = (error) => {
        cleanup();
        reject(error);
      };

      const onMessage = (event) => {
        if (!matches(event.data)) return;
        cleanup();
        resolve(event.data);
      };

      const onError = (event) => {
        cancel(new Error(event.message || 'Stockfish worker failed.'));
      };

      const timer = setTimeout(() => {
        cancel(new Error('Stockfish did not respond in time.'));
      }, timeoutMs);

      cancelPending.add(cancel);
      worker.addEventListener('message', onMessage);
      worker.addEventListener('error', onError, { once: true });
    });
  }

  async function start(skillLevel = 3) {
    if (readyPromise) return readyPromise;

    worker = new Worker('stockfish/stockfish-19-lite-single.js');

    readyPromise = (async () => {
      const uciReady = waitForReply((line) => line === 'uciok');
      worker.postMessage('uci');
      await uciReady;

      const clampedSkill = Math.max(0, Math.min(20, skillLevel));
      worker.postMessage(`setoption name Skill Level value ${clampedSkill}`);
      activeSkillLevel = clampedSkill;
      const engineReady = waitForReply((line) => line === 'readyok');
      worker.postMessage('isready');
      await engineReady;
    })();

    return readyPromise;
  }

  async function bestMove(fen, thinkMs = 500, skillLevel = 3) {
    await start(skillLevel);

    if (busy) throw new Error('Stockfish is already thinking.');
    busy = true;

    try {
      const clampedSkill = Math.max(0, Math.min(20, skillLevel));
      if (clampedSkill !== activeSkillLevel) {
        const engineReady = waitForReply((line) => line === 'readyok');
        worker.postMessage(`setoption name Skill Level value ${clampedSkill}`);
        worker.postMessage('isready');
        await engineReady;
        activeSkillLevel = clampedSkill;
      }

      const reply = waitForReply((line) => line.startsWith('bestmove '));
      worker.postMessage(`position fen ${fen}`);
      worker.postMessage(`go movetime ${thinkMs}`);

      const line = await reply;
      const move = line.split(' ')[1];
      if (!move || move === '(none)') {
        throw new Error('Stockfish did not return a move.');
      }
      return move;
    } finally {
      busy = false;
    }
  }

  function dispose() {
    for (const cancel of [...cancelPending]) {
      cancel(new Error('Stockfish worker was stopped.'));
    }
    worker?.terminate();
    worker = undefined;
    readyPromise = undefined;
    busy = false;
    activeSkillLevel = undefined;
  }

  return { start, bestMove, dispose };
})();
