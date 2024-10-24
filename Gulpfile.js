import { exec } from 'child_process';
import { glob } from 'glob'
import { rm } from 'fs/promises'
import { series } from 'gulp'
import { context as esBuildContext } from 'esbuild';
import { sassPlugin } from 'esbuild-sass-plugin'

const ENTRYPOINTS = 'app/javascript/*.{js,ts}{x,}';
const ENTRYPOINTS_IGNORE = '**/*.d.ts';
const OUT_DIR = 'app/assets/builds';
const ENV_CREDENTIALS = ['GOOGLE_MAPS_API_KEY'];

async function fetchCredential(name){
  const command = `bundle exec rails runner 'puts Rails.application.credentials.${name}!.to_json'`;
  console.log(`Running: ${command}`)
  return new Promise((resolve, reject) => {
    const proc = exec(command, (error, stdout, stderr) => {
      if (stderr.trim().length > 0) console.warn(`STDERR: ${stderr.trim()}`);
      if (stdout.trim().length > 0) console.log(`STDOUT: ${stdout}`);
      if (error) {
        reject(error);
      } else {
        resolve(stdout.toString().trim());
      }
    });
  })

}

async function fetchCredentials() {
  const result = {};
  for (const name of ENV_CREDENTIALS) {
    result[name.toUpperCase()] = await fetchCredential(name.toLowerCase());
  }
  return result;
}

async function buildConfig() {
  if (buildConfig.config) return buildConfig.config;
  buildConfig.config = {
    entryPoints: await glob(ENTRYPOINTS, { ignore: ENTRYPOINTS_IGNORE }),
    sourcemap: true,
    format: 'esm',
    plugins: [sassPlugin({
      embedded: true,
      quietDeps: true,
      cache: true,
    })],
    loader: {
      '.svg': 'dataurl'
    },
    outdir: OUT_DIR,
    publicPath: '/assets',
    define: {
      ...await fetchCredentials()
    },
    bundle: true,
  };
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
  await ctx.cancel();
  await ctx.dispose();
  cb();
}

export const watch = async (cb) => {
  const ctx = await buildContext();
  await ctx.watch();
  cb();
}

export default series(clean, build)