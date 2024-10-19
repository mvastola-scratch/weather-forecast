import { glob } from 'glob'
import { rm } from 'fs/promises'
import { series } from 'gulp'
import { context as esBuildContext } from 'esbuild';
import { sassPlugin } from 'esbuild-sass-plugin'

const ENTRYPOINTS = 'app/javascript/*.{js,ts}{x,}';
const ENTRYPOINTS_IGNORE = '**/*.d.ts';
const OUT_DIR = 'app/assets/builds';
const IMPORTED_ENV_VARS = ['GOOGLE_MAPS_API_KEY'];

async function buildConfig() {
  if (buildConfig.config) return buildConfig.config;
  buildConfig.config = {
    entryPoints: await glob(ENTRYPOINTS, { ignore: ENTRYPOINTS_IGNORE }),
    sourcemap: true,
    format: 'esm',
    plugins: [sassPlugin({
      quietDeps: true,
      cache: true,
    })],
    outdir: OUT_DIR,
    publicPath: '/assets',
    define: {},
    bundle: true,
  };
  IMPORTED_ENV_VARS.forEach(name => {
    buildConfig.config.define[name] = JSON.stringify(process.env[name] || null);
  });
  console.dir(buildConfig.config)
  return buildConfig.config;
}

async function buildContext(extraConfig = {}) {
  if (buildContext.ctx) return buildContext.ctx;
  const config = {
    ...await buildConfig(),
    ...extraConfig
  }
  buildContext.ctx = await esBuildContext(config);
  return buildContext.ctx;
}
export const clean = async (cb) => {
  console.log('Existing build files:')
  const buildFiles = await glob(`${OUT_DIR}/*.*`);
  console.dir(buildFiles);
  for (const path of buildFiles) await rm(path);
  cb();
}
export const build = async (cb) => {
  const ctx = await buildContext();
  const result = await ctx.rebuild();
  cb(result);
  return result;
}

export const watch = async (cb) => {
  const ctx = await buildContext();
  await ctx.watch();
  cb();
}

export default series(clean, build)