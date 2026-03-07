const fs = require('fs/promises');
const path = require('path');
const { PDFDocument } = require('pdf-lib');

const embedQrIntoPdf = async (pdfBuffer, qrPngBuffer) => {
  const pdfDoc = await PDFDocument.load(pdfBuffer);
  const qrImage = await pdfDoc.embedPng(qrPngBuffer);
  const firstPage = pdfDoc.getPages()[0];

  const qrSize = 110;
  const margin = 24;
  const x = firstPage.getWidth() - qrSize - margin;
  const y = margin;

  firstPage.drawImage(qrImage, {
    x,
    y,
    width: qrSize,
    height: qrSize
  });

  return Buffer.from(await pdfDoc.save());
};

const saveBufferToFile = async (fullPath, buffer) => {
  await fs.mkdir(path.dirname(fullPath), { recursive: true });
  await fs.writeFile(fullPath, buffer);
};

module.exports = { embedQrIntoPdf, saveBufferToFile };