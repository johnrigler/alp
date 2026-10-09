// Browser-independent behavior checks. This does not verify visual rendering.
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
class Element {
  constructor(tag = 'div') { this.tagName=tag; this.children=[]; this.dataset={}; this.attributes={}; this.listeners={}; this.value=''; }
  get childNodes() { return this.children; }
  get textContent() { return this.children.map(child => typeof child==='string' ? child : child.textContent).join(''); }
  set textContent(text) { this.children=[String(text)]; }
  set innerHTML(value) { throw new Error('Source rendering must not use innerHTML'); }
  append(...children) { this.children.push(...children); }
  replaceChildren(...children) { this.children=[...children]; }
  setAttribute(name,value) { this.attributes[name]=value; }
  addEventListener(name,listener) { this.listeners[name]=listener; }
  click() { if(this.onclick) this.onclick(); }
}
const selectors = ['#listing','#status','#source code','#media','#language','#copy','#download','#filter','#source','#filename','#directory','#reload','#folder'];
const elements = Object.fromEntries(selectors.map(selector=>[selector,new Element()]));
elements['#language'].value='auto';
const definitions = {
  '.files.txt':'source\tdemo-12345.1\nscript\ttools.js-02345678\nview\tunsafe.html\ndirectory\tsub\nview\t../escape\n',
  'demo-12345.1':'demo () { printf "%s\\n" "$value"; }\n',
  'tools.js-02345678':'function main() { return "two  spaces"; }\n',
  'unsafe.html':'<img src=x onerror="throw new Error(\'executed\')">\n<script>alert(1)</script>\n',
  'sub/.files.txt':'view\tnotes.txt\n',
  'sub/notes.txt':'a plain file\n'
};
const location = {href:'https://example.test/ipfs/cid/alp-view.html',pathname:'/ipfs/cid/alp-view.html',search:'',hash:'',protocol:'https:'};
let copied='', fetches=[], delayedBlob=null;
const context=vm.createContext({
  document:{querySelector:selector=>elements[selector],createElement:tag=>new Element(tag),createTextNode:text=>({textContent:text})},
  location, URL, URLSearchParams, Blob,
  history:{replaceState(_state,_title,url){ location.hash=url.includes('#')?'#'+url.split('#')[1]:''; }},
  navigator:{clipboard:{async writeText(text){copied=text;}}},
  window:{addEventListener(){}},
  setTimeout(){return 0;},clearTimeout(){},
  async fetch(url){
    const key=decodeURIComponent(new URL(url).pathname.replace('/ipfs/cid/','')); fetches.push(key);
    return {ok:key in definitions,status:key in definitions?200:404,async blob(){return key==='slow.txt' && delayedBlob ? delayedBlob : new Blob([definitions[key]||'']);}};
  }
});
const html=fs.readFileSync(path.join(__dirname,'../web/alp-view.html'),'utf8');
const script=html.match(/<script>([\s\S]*?)<\/script>/)[1];
new vm.Script(script); // Parse the actual delivered browser code.
vm.runInContext(script,context);
const run=code=>vm.runInContext(code,context);
const flush=()=>new Promise(resolve=>setImmediate(resolve));
(async()=>{
  await flush();
  assert.equal(run('entries.length'),4,'invalid paths must be filtered');
  await run('openFile("demo-12345.1")');
  assert.equal(elements['#source code'].textContent,definitions['demo-12345.1']);
  assert(elements['#source code'].children.some(token=>token.className==='tok-function'),'Bash function coloring');
  assert.equal(run('inferLanguage("tools.js-02345678", "function main() {}")'),'javascript');
  await run('openFile("tools.js-02345678")');
  assert(elements['#source code'].children.some(token=>token.className==='tok-keyword'),'JavaScript keyword coloring');
  await run('openFile("unsafe.html")');
  assert.equal(elements['#source code'].textContent,definitions['unsafe.html'],'markup must remain literal source');
  await elements['#copy'].onclick(); assert.equal(copied,definitions['unsafe.html'],'copy must preserve raw source');
  assert(location.hash.includes('file=unsafe.html'),'selected file must be in the URL');
  await run('openDirectory("sub", "notes.txt")');
  assert.equal(elements['#source code'].textContent,definitions['sub/notes.txt']);
  assert(location.hash.includes('dir=sub') && location.hash.includes('file=notes.txt'));
  assert(fetches.includes('sub/.files.txt'),'nested relative manifest fetch');
  const before=fetches.length; await run('openDirectory("../escape")'); assert.equal(fetches.length,before,'traversal must not fetch');

  // A stale text read must not corrupt the copy buffer of a newer selection.
  definitions['.files.txt']+='view\tslow.txt\n'; definitions['slow.txt']='slow';
  let resolveSlow;
  delayedBlob={size:4,text:()=>new Promise(resolve=>{resolveSlow=resolve;})};
  await run('openDirectory("")');
  const slow=run('openFile("slow.txt")'); await flush();
  await run('openFile("unsafe.html")'); resolveSlow('stale text'); await slow;
  await elements['#copy'].onclick(); assert.equal(copied,definitions['unsafe.html'],'stale read must not replace current source');

  // Local folder input works without a manifest and makes no HTTP requests.
  const local=new Blob(['print("local")\n']); local.webkitRelativePath='local folder/local.py';
  const beforeLocal=fetches.length;
  await elements['#folder'].listeners.change({target:{files:[local]}});
  await run('openFile("local.py")');
  assert.equal(elements['#source code'].textContent,'print("local")\n');
  assert.equal(fetches.length,beforeLocal,'local file access must not upload or fetch');
  const samples=['a () { printf "$x"; }\n# comment\n','const x = `a <b>`; // comment\n','def f():\n  return "x"\n','{"n":12,"b":true}\n','<p title="x">text</p>','a { color: red; }'];
  for(const language of ['bash','javascript','python','json','html','css','text']) {
    for(const text of samples) assert.equal(context.colorTokens(text,language).map(token=>token.text).join(''),text,'coloring must preserve every byte');
  }
  console.log('All viewer parsing and behavior checks passed (no browser rendering).');
})().catch(error=>{console.error(error);process.exitCode=1;});
