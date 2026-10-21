// Author with the supplied Artifact Tool runtime; never installs dependencies.
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { createRequire } from 'node:module';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const modules = process.env.RUNTIME_NODE_MODULES;
const skill = process.env.PRESENTATIONS_SKILL_DIR;
const python = process.env.RUNTIME_PYTHON;
if (![modules, skill, python].every(value => value && path.isAbsolute(value))) {
  throw new Error('Set absolute RUNTIME_NODE_MODULES, PRESENTATIONS_SKILL_DIR and RUNTIME_PYTHON from the supplied runtime.');
}
const require = createRequire(path.join(modules, '__presentation_runtime.cjs'));
const { Presentation, PresentationFile } = await import(pathToFileURL(require.resolve('@oai/artifact-tool')).href);
const { finalizePresentation } = await import(pathToFileURL(path.join(skill, 'container_tools/artifact_tool_utils.mjs')).href);
const data = JSON.parse(await fs.readFile(path.join(root, 'docs/presentations/technology-tooling-overview.json'), 'utf8'));
const build = path.join(root, '.codex-build/manus-presentation');
const final = path.resolve(root, process.argv[2] ?? 'docs/presentations/technology-tooling-overview.pptx');
const outputRelative = path.relative(root, final);
if (!outputRelative || outputRelative.startsWith('..') || path.isAbsolute(outputRelative) ||
    path.extname(final).toLowerCase() !== '.pptx' || final.startsWith(build + path.sep)) {
  throw new Error('Choose a new .pptx output inside the repository, outside the private build directory.');
}
await fs.mkdir(build, { recursive: true });
await fs.mkdir(path.dirname(final), { recursive: true });
const deck = Presentation.create({ slideSize: { width: 1280, height: 720 } });

function text(slide, value, x, y, width, height, size = 29, bold = false, color = '#202927', font = 'Cambria') {
  const shape = slide.shapes.add({ geometry: 'textbox', name: `text-${slide.shapes.items.length + 1}`,
    position: { left: x, top: y, width, height }, fill: 'none', line: { fill: 'none', width: 0 } });
  shape.text = [{ runs: [{ run: value, style: { typeface: font, fontSize: `${size}px`, bold, color } }] }];
  shape.text.style = { fontSize: size, verticalAlignment: 'top', insets: 0, wrap: 'word' };
  return shape;
}

for (const [index, content] of data.slides.entries()) {
  const slide = deck.slides.add();
  const cover = content.kind === 'cover';
  slide.background.fill = cover ? '#173D37' : '#F6F3EB';
  if (cover) {
    text(slide, content.title, 78, 115, 1100, 240, 80, true, '#F6F3EB');
    text(slide, content.subtitle, 82, 405, 1070, 120, 35, false, '#E5E7DC');
    text(slide, 'ULTIMATE KI SETUP  /  OKTOBER 2026', 82, 620, 1000, 34, 20, false, '#E5E7DC', 'Consolas');
  } else {
    text(slide, content.title, 78, 65, 1125, 105, 47, true);
    if (content.kind === 'code') {
      text(slide, content.code, 82, 218, 745, 310, 28, false, '#173D37', 'Consolas');
      text(slide, content.aside, 855, 218, 345, 340, 28);
    } else {
      for (const [row, [label, body]] of content.items.entries()) {
        const top = 205 + row * 134;
        text(slide, label, 82, top, 1080, 45, 31, true, '#173D37');
        text(slide, body, 82, top + 49, 1080, 70, 29);
      }
    }
    text(slide, `${String(index + 1).padStart(2, '0')}  /  ${String(data.slides.length).padStart(2, '0')}`, 1090, 660, 115, 28, 17, false, '#59645E', 'Consolas');
  }
  slide.speakerNotes.text = `${content.note}\n\nQuellen:\n${content.sources.join('\n')}`;
}

// Render and inspect each preview before handing off the separately finalized file.
for (const [index, slide] of deck.slides.items.entries()) {
  const blob = await deck.export({ slide, format: 'png', scale: 1 });
  await fs.writeFile(path.join(build, `slide-${String(index + 1).padStart(2, '0')}.png`), new Uint8Array(await blob.arrayBuffer()));
}
const candidate = path.join(build, 'candidate.pptx');
await (await PresentationFile.exportPptx(deck)).save(candidate);
const result = await finalizePresentation({
  workspaceDir: root, candidatePath: candidate, finalPath: final, pythonExecutable: python,
  integrityValidatorPath: path.join(skill, 'container_tools/inspect_presentation_package_integrity.py'),
  layoutValidatorPath: path.join(skill, 'container_tools/inspect_presentation_layout_geometry.py'),
  layoutArgs: ['--expected-slide-size-emu', '12192000,6858000', '--validate-heading-fit'],
  explicitTotalSlideCount: data.slides.length,
  fontPolicy: { basis: 'design', families: ['Cambria', 'Consolas'] },
  verifyArtifactToolImport: true,
  receiptPath: path.join(build, 'validation.json'),
});
console.log(JSON.stringify({ final, slides: data.slides.length, result }));
if (result.packageIntegrity.exitCode !== 0 || result.presentationLayout.exitCode !== 0 ||
    result.firstPartyImport.passed !== true) {
  throw new Error('Presentation finalization did not pass.');
}
// The library may leave a probe exit code set even after successful finalization.
process.exitCode = 0;
