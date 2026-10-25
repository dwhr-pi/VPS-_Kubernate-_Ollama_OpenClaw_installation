/* Explicit planning assumptions, not model benchmarks or Kubernetes control. */
(function (scope) {
  'use strict';
  const defaults = Object.freeze({parameters: 8, bits: 4, context: 4096, kvKiB: 128,
    parallel: 1, runtimeGi: 1, cpuPerSlot: 1, ramGi: 16, cpu: 4, diskGi: 120,
    reservedGi: 2, reservedCpu: 0.75, pvcGi: 50, nodes: 1, maxNodes: 4,
    maxPods: 8, rpm: 6, serviceSeconds: 30, target: 0.7, coldSeconds: 60,
    nodeSeconds: 180, autoscale: true});
  function validate(raw) {
    const p = {...defaults, ...raw};
    for (const key of Object.keys(defaults)) {
      if (key === 'autoscale') continue;
      if (!Number.isFinite(p[key]) || p[key] < 0 || p[key] > 1e7) throw new Error('Ungueltiger Zahlenwert: ' + key);
    }
    for (const key of ['parameters', 'context', 'parallel', 'ramGi', 'cpu', 'diskGi',
      'pvcGi', 'nodes', 'maxNodes', 'maxPods', 'serviceSeconds', 'cpuPerSlot']) {
      if (p[key] <= 0) throw new Error('Wert muss positiv sein: ' + key);
    }
    for (const key of ['context', 'parallel', 'nodes', 'maxNodes', 'maxPods']) {
      if (!Number.isInteger(p[key])) throw new Error('Ganzzahl erforderlich: ' + key);
    }
    if (![4, 8, 16].includes(p.bits) || p.target <= 0 || p.target > 1 || p.maxNodes < p.nodes ||
        p.maxNodes > 100 || p.maxPods > 1000 || p.parallel > 128 || typeof p.autoscale !== 'boolean') {
      throw new Error('Quantisierung, Zielwert oder Skalierungsgrenzen ungueltig.');
    }
    return p;
  }
  function plan(raw) {
    const p = validate(raw);
    // All total parameters reside in RAM: no assumed GPU offload or expert streaming.
    const weightGi = p.parameters * 1e9 * (p.bits / 8) / (1024 ** 3) * 1.15;
    const kvGi = p.kvKiB * p.context * p.parallel / (1024 ** 2);
    const podGi = (weightGi + kvGi + p.runtimeGi) * 1.15;
    const podCpu = p.parallel * p.cpuPerSlot;
    const ramFit = Math.max(0, Math.floor((p.ramGi - p.reservedGi) / podGi));
    const cpuFit = Math.max(0, Math.floor((p.cpu - p.reservedCpu) / podCpu));
    const diskFit = Math.floor(p.diskGi * 0.85 / p.pvcGi);
    const storageValid = p.pvcGi >= weightGi * 1.3;
    const podsPerNode = storageValid ? Math.min(ramFit, cpuFit, diskFit) : 0;
    const offeredSlots = p.rpm / 60 * p.serviceSeconds;
    const requestedPods = Math.max(1, Math.ceil(offeredSlots / (p.parallel * p.target)));
    const desiredPods = Math.min(requestedPods, p.maxPods);
    const requiredNodes = podsPerNode ? Math.ceil(desiredPods / podsPerNode) : null;
    return {p, weightGi, kvGi, podGi, podCpu, ramFit, cpuFit, diskFit, storageValid,
      podsPerNode, offeredSlots, requestedPods, desiredPods, requiredNodes,
      currentCapacity: Math.min(p.maxPods, podsPerNode * p.nodes),
      maxCapacity: Math.min(p.maxPods, podsPerNode * p.maxNodes),
      totalPvcGi: desiredPods * p.pvcGi,
      expectedActive: offeredSlots, overloaded: requestedPods > Math.min(p.maxPods, podsPerNode * p.maxNodes)};
  }
  function simulate(raw) {
    const result = plan(raw), p = result.p;
    let nodes = p.nodes, pods = result.currentCapacity > 0 ? 1 : 0, queue = 0;
    let nodePending = null;
    const pending = [], rows = [], step = 10;
    for (let time = 0; time <= 600; time += step) {
      if (nodePending !== null && time >= nodePending) {nodes++; nodePending = null;}
      for (let i = pending.length - 1; i >= 0; i--) {
        if (pending[i] <= time) {pods++; pending.splice(i, 1);}
      }
      if (time > 0) queue = Math.max(0, queue + p.rpm / 60 * step - pods * p.parallel / p.serviceSeconds * step);
      const wanted = Math.min(p.maxPods, Math.max(1,
        Math.ceil((result.offeredSlots + queue) / (p.parallel * p.target))));
      const capacity = Math.min(p.maxPods, nodes * result.podsPerNode);
      if (p.autoscale && time % 30 === 0) {
        if (wanted > capacity && nodes < p.maxNodes && result.podsPerNode > 0 && nodePending === null) {
          nodePending = time + Math.max(step, p.nodeSeconds);
        }
        const toStart = Math.max(0, Math.min(wanted, capacity) - pods - pending.length);
        for (let i = 0; i < toStart; i++) pending.push(time + Math.max(step, p.coldSeconds));
      }
      rows.push({time, queue, nodes, pods, pending: pending.length,
        wanted, throughputRpm: pods * p.parallel / p.serviceSeconds * 60});
    }
    return {...result, rows};
  }
  const api = {defaults, validate, plan, simulate};
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else scope.ResourcePlanner = api;
})(typeof globalThis !== 'undefined' ? globalThis : this);
