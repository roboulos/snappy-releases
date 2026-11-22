// download.snappy.ai: the permanent link to the newest Snappy for macOS. GitHub serves the file; this only points at it.
const LATEST = "https://github.com/roboulos/snappy-releases/releases/latest/download/Snappy.zip";

export default {
  fetch() {
    return Response.redirect(LATEST, 302);
  },
};
