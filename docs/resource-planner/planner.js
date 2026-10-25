'use strict';
const form = document.getElementById('controls');
const text = (id, value) => { document.getElementById(id).textContent = value; };
function render() {
  const status = document.getElementById('status');
  try {
    const raw = {};
    for (const control of form.elements) {
      if (control.name) raw[control.name] = control.type === 'checkbox' ? control.checked : Number(control.value);
    }
    const r = ResourcePlanner.simulate(raw), last = r.rows[r.rows.length - 1];
    const messages = [];
    if (!r.storageValid) messages.push('PVC zu klein fuer Gewichte und Cache-Reserve.');
    if (!r.podsPerNode) messages.push('Ein Pod passt nicht auf diesen Node. Mehr gleich kleine Nodes beheben das nicht.');
    if (r.overloaded) messages.push('Pod-/Node-Grenze reicht fuer die eingestellte Last nicht aus.');
    if (r.requiredNodes > r.p.maxNodes) messages.push('Erforderliche Nodes liegen ueber dem Maximum.');
    status.dataset.error = String(messages.length > 0);
    status.textContent = messages.join(' ') || 'Rechnerisch planbar. Messung, Storage- und Sicherheitsabnahme bleiben erforderlich.';
    text('podRam', r.podGi.toFixed(2) + ' GiB');
    text('fit', r.podsPerNode);
    text('wanted', r.desiredPods + ' / ' + r.requestedPods);
    text('nodeCount', r.requiredNodes === null ? 'Nicht planbar' : r.requiredNodes);
    text('summary', 'Nach 10 Minuten: ' + last.nodes + ' Nodes, ' + last.pods + ' bereite Pods, Queue ' + last.queue.toFixed(1) +
      '. Geplante PVC-Summe: ' + r.totalPvcGi + ' GiB. Schwebende Anfragen im Mittel: ' + r.expectedActive.toFixed(1) + '.');
    const ns = 'http://www.w3.org/2000/svg', svg = document.getElementById('queueChart');
    svg.replaceChildren();
    const max = Math.max(1, ...r.rows.map(row => row.queue));
    function shape(tag, attrs, value) {
      const node = document.createElementNS(ns, tag);
      for (const [key, val] of Object.entries(attrs)) node.setAttribute(key, val);
      if (value !== undefined) node.textContent = value;
      svg.appendChild(node); return node;
    }
    shape('line', {x1:45,y1:185,x2:680,y2:185,class:'axis'});
    shape('line', {x1:45,y1:20,x2:45,y2:185,class:'axis'});
    shape('text', {x:5,y:25,class:'axis-label'}, max.toFixed(0));
    shape('text', {x:12,y:185,class:'axis-label'}, '0');
    shape('text', {x:45,y:210,class:'axis-label'}, '0 min');
    shape('text', {x:620,y:210,class:'axis-label'}, '10 min');
    const points = r.rows.map(row => (45 + row.time / 600 * 635).toFixed(2) + ',' + (185 - row.queue / max * 155).toFixed(2)).join(' ');
    shape('polygon', {points:'45,185 ' + points + ' 680,185',class:'queue-fill'});
    shape('polyline', {points,class:'queue-line'});
    const tbody = document.getElementById('timeline'); tbody.replaceChildren();
    for (const row of r.rows.filter(row => row.time % 60 === 0)) {
      const tr = document.createElement('tr');
      for (const value of [row.time / 60 + ' min', row.nodes, row.pods, row.pending, row.queue.toFixed(1)]) {
        const td = document.createElement('td'); td.textContent = value; tr.appendChild(td);
      }
      tbody.appendChild(tr);
    }
  } catch (error) {
    status.dataset.error = 'true'; status.textContent = error.message;
    for (const id of ['podRam','fit','wanted','nodeCount','summary']) text(id, '-');
    document.getElementById('queueChart').replaceChildren();
    document.getElementById('timeline').replaceChildren();
  }
}
form.addEventListener('input', render);
form.addEventListener('submit', event => event.preventDefault());
form.addEventListener('reset', () => setTimeout(render, 0));
document.getElementById('profile').addEventListener('change', event => {
  form.elements.parameters.value = event.target.value;
  render();
});
render();
