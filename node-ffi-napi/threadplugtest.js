const {
  Worker, isMainThread, parentPort, workerData
} = require('worker_threads');


//console.log(`Loading libplugtest from worker ${isMainThread ? 'MAIN' : 'NOT-MAIN'}`);
//let libplugtest = require('./libplugtest');
//console.log(`Loaded libplugtest from worker ${isMainThread ? 'MAIN' : 'NOT-MAIN'}`);

if (isMainThread) {
  console.log('isMainThread of threadplugtest.js');
  module.exports = async function testThreadPlugTest(input) {
    return new Promise((resolve, reject) => {
      const worker = new Worker(__filename, { workerData: { input: input } });
      worker.on('message', resolve);
      worker.on('error', reject);
      worker.on('exit', (code) => {
        if (code !== 0)
          reject(new Error(`Worker stopped with exit code ${code}`));
      });
      console.log('Calling worker.postMessage(input)');
      worker.postMessage(input);
    });
  };
} else {
  console.log('NOT isMainThread of threadplugtest.js');
  console.log("workerData", workerData);
  console.log('Loading libplugtest.js');
  let libplugtest = require('./libplugtest');
  console.log('Calling libplugtest.toUpperInGo from NOT isMainThread');
  let result = libplugtest.toUpperInGo(workerData.input);
  console.log('Calling parentPort.postMessage from NOT isMainThread');
  parentPort.postMessage({ output: result });
}
