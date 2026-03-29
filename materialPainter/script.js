// define outside
let exportMaterialsBTN,exportMaterialsAllBTN,
  exportColorsBTN,
  selectAll,
  deselectAll,
  colorEditorPicker,
  colorEditorName,
  colorEditorBox,
  colorEditorShading,
  colorEditorNew,
  colorEditorRemove,
  colorEditorSave,
  colorsInfoText,
  materialsInfoText,
  logsElement,
  clearMaterialsBTN,
  clearColorsBTN,
  colorVariantsList;

let activeColor = "#777777";
let colorList = [];
let logs = [];

// assign inside onload once DOM is ready
window.onload = () => {
  exportMaterialsBTN = document.getElementById("exportMaterials");
  exportMaterialsAllBTN = document.getElementById("exportMaterialsAll");
  exportColorsBTN = document.getElementById("exportColors");
  selectAll = document.getElementById("selectAll");
  deselectAll = document.getElementById("deselectAll");
  colorEditorPicker = document.getElementById("colorPicker");
  colorEditorName = document.getElementById("colName");
  colorEditorBox = document.getElementById("colorEditorBox");
  colorEditorShading = document.querySelectorAll(".shadingBall");
  colorEditorNew = document.getElementById("colorEditorNew");
  colorEditorRemove = document.getElementById("colorEditorRemove");
  colorEditorSave = document.getElementById("colorEditorSave");
  colorVariantsList = document.getElementById("colorVariantsList");
  colorsInfoText = document.getElementById("colorsInfoText");
  materialsInfoText = document.getElementById("materialsInfoText");
  clearMaterialsBTN = document.getElementById("clearMaterials");
  clearColorsBTN = document.getElementById("clearColors");

  logsElement = document.getElementById("logs");
  log("Window loaded.");

  registerFileInput("materialsUpload", "sourceMaterial");
  registerFileInput("colorsUpload", "colorVariants");

  // Load Stored File
  const sourceMaterialJson = loadFromStorage("sourceMaterial");
  if (sourceMaterialJson) {
    populateMaterialList(sourceMaterialJson);
    filename = localStorage.getItem("sourceMaterial_filename");
    materialsInfoText.innerText = `${filename} loaded.`;
    log(`${filename} loaded.`);
  }
  const colorVariantsJson = loadFromStorage("colorVariants");
  if (colorVariantsJson) {
    populateColorListFromStorage(colorVariantsJson);
    filename = localStorage.getItem("colorVariants_filename");
    colorsInfoText.innerText = `${filename} loaded.`;
    log(`${filename} loaded.`);
  }

  exportColorsBTN.addEventListener("click", function (e) {
    exportColors();
  });
  exportMaterialsBTN.addEventListener("click", function (e) {
    exportMaterials();
  });
  exportMaterialsAllBTN.addEventListener("click", function (e) {
    exportMaterials(true);
  });
  selectAll.addEventListener("click", function (e) {
    toggleAllMaterials(true);
  });
  deselectAll.addEventListener("click", function (e) {
    toggleAllMaterials(false);
  });
  colorEditorSave.addEventListener("click", function (e) {
    addColor();
  });
  colorEditorRemove.addEventListener("click", function (e) {
    removeColor();
  });
  colorEditorNew.addEventListener("click", function (e) {
    resetColorEditor();
  });
  colorEditorPicker.addEventListener("input", (e) => {
    activeColor = e.target.value;
    updateColorEditorColors();
  });

  clearMaterialsBTN.addEventListener("click", function (e) {
    removeFromStorage("sourceMaterial");
    populateMaterialList({})
  });
  clearColorsBTN.addEventListener("click", function (e) {
    removeFromStorage("colorVariants");
    populateColorList()
  });
  // Default Blank State
  resetColorEditor();
};

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

function registerFileInput(id, storageKey) {
  let upload = document.getElementById(id);

  if (!upload) {
    console.error(`Input #${id} not found`);
    log(`Input #${id} not found`, true);

    return;
  }

  upload.addEventListener("change", function () {
    if (upload.files.length === 0) return;

    let reader = new FileReader();

    reader.addEventListener("load", function () {
      let result = JSON.parse(reader.result);
      localStorage.setItem(storageKey, JSON.stringify(result));
      localStorage.setItem(`${storageKey}_filename`, upload.files[0].name);
      console.log(`JSON Stored under key: ${storageKey}`);

      if (storageKey === "sourceMaterial") {
        populateMaterialList(result);
        filename = localStorage.getItem("sourceMaterial_filename");
        materialsInfoText.innerText = `${filename} loaded.`;
        log(`${filename} loaded.`);
      }
      if (storageKey === "colorVariants") {
        populateColorListFromStorage(result);
        filename = localStorage.getItem("colorVariants_filename");
        colorsInfoText.innerText = `${filename} loaded.`;
        log(`${filename} loaded.`);
      }
    });

    reader.readAsText(upload.files[0]);
  });
}

function removeFromStorage(storageKey) {
  localStorage.removeItem(storageKey);
  localStorage.removeItem(`${storageKey}_filename`);
}

function loadFromStorage(storageKey) {
  return JSON.parse(localStorage.getItem(storageKey) || "null");
}

function downloadJSON(data, filename = "variants.materials.json") {
  const json = JSON.stringify(data, null, 2);
  const blob = new Blob([json], { type: "application/json" });
  const url = URL.createObjectURL(blob);

  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  a.click();

  URL.revokeObjectURL(url); // clean up
}
/*Materials*/

function populateMaterialList(materialsJSON) {
  let materialList = document.getElementById("sourceMaterialList");
  materialList.innerHTML = ""; // clear existing

  Object.values(materialsJSON).forEach((material) => {
    const label = document.createElement("label");
    const checkbox = document.createElement("input");
    const box = document.createElement("label");
    const checkIcon = document.createElement("span");

    box.classList.add("material");
    box.htmlFor = material.name;

    checkbox.type = "checkbox";
    checkbox.value = material.name;
    checkbox.id = material.name;

    label.htmlFor = material.name;
    label.textContent = material.name;

    checkIcon.textContent = "✓";
    checkIcon.classList.add("checkIcon");

    box.appendChild(checkbox);
    box.appendChild(label);
    box.appendChild(checkIcon);

    materialList.appendChild(box);
  });
  log(`Materials list loaded.`);
}

function getMaterialCheckboxes() {
  return document.querySelectorAll(
    "#sourceMaterialList input[type='checkbox']",
  );
}

function getSelectedMaterials() {
  let checkboxes = getMaterialCheckboxes();
  return Array.from(checkboxes)
    .filter((cb) => cb.checked)
    .map((cb) => cb.value);
}

function setSelectedMaterials(materials) {
  let checkboxes = getMaterialCheckboxes();

  checkboxes.forEach((checkbox) => {
    checkbox.checked = materials.includes(checkbox.value);
  });
}

function toggleAllMaterials(checked) {
  let checkboxes = getMaterialCheckboxes();

  checkboxes.forEach((checkbox) => {
    checkbox.checked = checked;
  });
  log(`All Materials have been ${checked ? "selected" : "deselected"}.`);
}

/* Colors*/
function populateColorListFromStorage(materialsJSON) {
  setSelectedMaterials(materialsJSON.variants);

  // clear existing entries
  colorList = [];
  // Populate the color list
  colorList = Object.entries(materialsJSON.colors);
  populateColorList();
  
}

function populateColorList() {
  colorVariantsList.innerHTML = ""; // clear existing

  //First sort the list
  colorList.sort(([nameA], [nameB]) => nameA.localeCompare(nameB));

  colorList.forEach(([name, hex]) => {
    const box = document.createElement("div");
    const colorBox = document.createElement("div");
    const text = document.createElement("p");

    box.classList.add("colorVariant");
    box.addEventListener("click", function (e) {
      loadColorIntoEditor(name, hex);
    });

    colorBox.style.backgroundColor = hex;
    colorBox.classList.add("colorBox");
    text.innerText = name;

    box.appendChild(colorBox);
    box.appendChild(text);
    colorVariantsList.appendChild(box);
  });
  log("Color list has been updated.");
}

function loadColorIntoEditor(name, hex, silent) {
  hex = hex.slice(0, 7); // Remove alpha
  colorEditorPicker.value = hex;
  activeColor = hex;
  colorEditorName.value = name;
  updateColorEditorColors();
  silent ? "" : log(`Color '${name}' loaded into editor.`);
}

function resetColorEditor() {
  loadColorIntoEditor("material", "#ffffff", true);
  log("Default material loaded into editor.");
}

function removeColor() {
  colorList = colorList.filter(([name]) => name !== colorEditorName.value);
  log(`Color '${colorEditorName.value}' has been removed.`);
  populateColorList();
  resetColorEditor();
}

function addColor() {
  const materialName = colorEditorName.value;
  const hex = colorEditorPicker.value;

  // Remove material if it exists
  if (colorList.find(([name]) => name === materialName)) {
    removeColor(materialName);
    log(`Color ${materialName} saved to the list.`);
  } else {
    log(`Color ${materialName} added to the list.`);
  }

  // Add or update material
  colorList.push([materialName, hex]);
  populateColorList();
}

function updateColorEditorColors() {
  colorEditorBox.style.background = activeColor;
  Array.from(colorEditorShading).forEach((e) => {
    e.style.background = activeColor;
  });
}

// Export Related

function exportMaterials(combine) {
  const materialsToGenerateKey = getSelectedMaterials();
  console.log(materialsToGenerateKey);
  if (materialsToGenerateKey.length === 0) {
    log("No Materials Selected, Canceling Export.", true);
    return;
  }
  const sourceMaterials = loadFromStorage("sourceMaterial");
  const colorVariantsJson = loadFromStorage("colorVariants");

  let outputJSON = combine ?  sourceMaterials : {}

  Object.entries(sourceMaterials)
    .filter(([key]) => materialsToGenerateKey.includes(key))
    .forEach(([key, material]) => {
      Object.entries(colorVariantsJson.colors).forEach(([colorName, hex]) => {
        const variant = createMaterialVariant(
          { [key]: material },
          hex,
          colorName,
        );
        Object.assign(outputJSON, variant); // merge into output
      });
    });
  log("Generated Materials JSON.");
  downloadJSON(outputJSON);
}

function exportColors() {
  // Process Colors
  colors = {};
  colorList.forEach(([name, hex]) => {
    colors[name] = hex.toUpperCase();
  });
  // Create Object
  colorsFile = {
    isHex: true,
    variants: getSelectedMaterials(),
    colors: colors,
  };
  downloadJSON(colorsFile, "export.colors.json");
}

function createMaterialVariant(materialJSON, variantHex, variantName) {
  let outputJSON = JSON.parse(JSON.stringify(materialJSON)); // deep clone

  const oldKey = Object.keys(outputJSON)[0]; // get the first (only) key
  const newKey = `${oldKey}_${variantName}`;
  log(`Generating JSON for ${newKey}`);

  // Rename key, name and mapTo
  outputJSON[oldKey].name = newKey;
  outputJSON[oldKey].mapTo = newKey;
  outputJSON[newKey] = outputJSON[oldKey];
  delete outputJSON[oldKey];

  // Convert hex to RGBA
  const rgba = hexToRGBA(variantHex);

  // Place baseColorFactor in each stage
  outputJSON[newKey].Stages = outputJSON[newKey].Stages.map((stage) => {
    // Check if stage has any keys beyond metallicFactor, or if metallicFactor is not null
    const hasContent = Object.values(stage).some((value) => value !== null);

    if (hasContent) {
      return { ...stage, baseColorFactor: rgba };
    }
    return stage; // leave empty stages untouched
  });
  return outputJSON;
}

function hexToRGBA(hex) {
  const r = parseInt(hex.slice(1, 3), 16) / 255;
  const g = parseInt(hex.slice(3, 5), 16) / 255;
  const b = parseInt(hex.slice(5, 7), 16) / 255;
  const a = parseInt(hex.slice(7, 9), 16) / 255;
  return [r, g, b, a];
}
