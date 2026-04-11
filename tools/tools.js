function createLoader() {
  const frames = ["[|]", "[/]", "[—]", "[\\]"];
  let frame = 0;

  const p = document.createElement("p");
  const span = document.createElement("span");
  const text = document.createTextNode(frames[0]);

  span.classList.add("time");
  span.innerText = getDateStr(new Date());

  const interval = setInterval(() => {
    span.innerText = getDateStr(new Date());
    text.nodeValue = frames[frame % frames.length];
    frame++;
  }, 150);

  p.appendChild(span);
  p.appendChild(text);

  logsElement._throbberInterval = interval;
  return p;
}
function getDateStr(date) {
  return ` [${String(date.getHours()).padStart(2, "0")}:${String(date.getMinutes()).padStart(2, "0")}:${String(date.getSeconds()).padStart(2, "0")}.${String(date.getMilliseconds()).padStart(3, "0")}]`;
}
function log(message, error = false) {
  error ? console.error(message) : console.log(message)

  const date = new Date();
  dateStr = getDateStr(date);
  logs.push([message, error, dateStr]);
  logsElement.innerHTML = "";
  logsElement.appendChild(createLoader()); // always first

  [...logs].reverse().forEach(([message, error, dateStr], index) => {
    const p = document.createElement("p");
    const span = document.createElement("span");
    const text = document.createTextNode(message);

    const opacity = 1 - index * 0.025;
    p.style.opacity = Math.max(opacity, 0.1);

    span.classList.add("time");
    span.innerText = dateStr;

    if (error) {
      p.classList.add("error");
    }

    p.appendChild(span);
    p.appendChild(text);
    logsElement.appendChild(p);
  });
}