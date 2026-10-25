'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const model = require('../docs/resource-planner/model.js');
test('weights use total parameters and GiB conversion', () => {
  const r = model.plan({parameters: 31, bits: 4});
  assert.equal(r.weightGi, 31e9 * 0.5 / (1024 ** 3) * 1.15);
  assert.ok(model.plan({parameters: 26}).weightGi > model.plan({parameters: 4}).weightGi);
});
test('KV cache grows with context and parallel slots', () => {
  const one = model.plan({parallel: 1, context: 4096});
  assert.equal(model.plan({parallel: 2, context: 8192}).kvGi, one.kvGi * 4);
});
test('more identical nodes never fix a pod too large for one node', () => {
  const r = model.plan({parameters: 31, ramGi: 8, maxNodes: 20});
  assert.equal(r.podsPerNode, 0);
  assert.equal(r.requiredNodes, null);
  assert.equal(r.maxCapacity, 0);
});
test('PVC too small cannot be treated as usable capacity', () => {
  assert.equal(model.plan({parameters: 31, pvcGi: 2, ramGi: 128}).podsPerNode, 0);
});
test('idle traffic requests at least one pod but no queue', () => {
  const r = model.simulate({rpm: 0});
  assert.equal(r.desiredPods, 1);
  assert.ok(r.rows.every(row => row.queue === 0));
});
test('concurrency and target headroom increase desired pods', () => {
  assert.ok(model.plan({rpm: 20}).requestedPods > model.plan({rpm: 2}).requestedPods);
  assert.ok(model.plan({target: 0.5}).requestedPods >= model.plan({target: 0.85}).requestedPods);
});
test('simulation respects CPU/RAM/disk, node and replica bounds', () => {
  const r = model.simulate({rpm: 120, maxNodes: 3, maxPods: 4});
  assert.ok(r.rows.every(row => row.nodes <= 3 && row.pods + row.pending <= 4));
  assert.ok(r.rows.every(row => row.pods + row.pending <= row.nodes * r.podsPerNode));
  assert.ok(r.rows.every(row => row.queue >= 0));
});
test('without autoscaling a single warm pod stays single', () => {
  const r = model.simulate({autoscale: false, rpm: 120});
  assert.ok(r.rows.every(row => row.nodes === 1 && row.pods === 1 && row.pending === 0));
  assert.ok(r.rows.at(-1).queue > 0);
});
test('cold start delays readiness and node provisioning', () => {
  const r = model.simulate({nodes: 1, maxNodes: 4, diskGi: 60, nodeSeconds: 180, coldSeconds: 60});
  assert.ok(r.rows.filter(row => row.time < 180).every(row => row.nodes === 1));
  assert.ok(r.rows.filter(row => row.time < 240).every(row => row.pods === 1));
});
test('invalid numeric inputs fail closed', () => {
  for (const value of [{rpm: NaN}, {context: Infinity}, {parallel: 0}, {nodes: 1.5},
    {target: 0}, {target: 2}, {bits: 3}, {nodes: 3, maxNodes: 2}, {serviceSeconds: 0}]) {
    assert.throws(() => model.plan(value));
  }
});
test('model has no network or mutable defaults', () => {
  const defaults = JSON.stringify(model.defaults);
  model.simulate({rpm: 100});
  assert.equal(JSON.stringify(model.defaults), defaults);
  for (const file of ['model.js', 'planner.js', 'index.html']) {
    const source = fs.readFileSync(path.join(__dirname, '../docs/resource-planner', file), 'utf8');
    assert.doesNotMatch(source, /\bfetch\s*\(|XMLHttpRequest|WebSocket|localStorage|eval\s*\(/);
  }
});
