// planted fault: the removed download.snappy.ai Worker, which the gate must refuse
export default { fetch() { return Response.redirect("https://github.com/roboulos/snappy-releases/releases/latest/download/Snappy.zip", 302); } };
