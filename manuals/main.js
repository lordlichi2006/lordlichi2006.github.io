/**
 * Renderiza un archivo Markdown en un <github-md>
 * @param {string} filePath - Ruta relativa al archivo .md
 */
async function renderMarkdownFile(filePath) {
    const container = document.getElementById('markdown-container');
    if (!container) {
        console.error('No se encontró #markdown-container');
        return;
    }

    try {
        const response = await fetch(filePath);
        if (!response.ok) throw new Error('File not found');

        const text = await response.text();
        container.innerHTML = escapeHTML(text);

        // Forzar renderizado si ya está cargado el script de Markdown-Tag
        if (typeof renderMarkdown === "function") {
            renderMarkdown();
        }
    } catch (err) {
        container.textContent = 'Error loading file: ' + err.message;
    }
}

/**
 * Escapa HTML para evitar XSS
 */
function escapeHTML(str) {
    return str.replace(/&/g, "&amp;")
              .replace(/</g, "&lt;")
              .replace(/>/g, "&gt;");
}

/**
 * Descarga múltiples archivos en un ZIP
 * @param {string[]} files - Array con nombres de archivos (relativos)
 * @param {string} zipName - Nombre del ZIP
 */
async function downloadFiles(files, zipName = 'manual.zip') {
    const zip = new JSZip();

    try {
        for (const file of files) {
            const response = await fetch(file);
            if (!response.ok) throw new Error(`No se pudo cargar: ${file}`);
            const text = await response.text();
            zip.file(file, text);
        }
        const content = await zip.generateAsync({ type: 'blob' });
        saveAs(content, zipName);
    } catch (error) {
        alert('Error al crear ZIP: ' + error.message);
        console.error(error);
    }
}