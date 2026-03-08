const fs = require('fs/promises');
const path = require('path');
const { PDFDocument } = require('pdf-lib');

const embedQrIntoPdf = async (pdfBuffer, qrPngBuffer) => {
  const pdfDoc = await PDFDocument.load(pdfBuffer);
  const qrImage = await pdfDoc.embedPng(qrPngBuffer);
  const firstPage = pdfDoc.getPages()[0];

  const pageWidth = firstPage.getWidth();
  const pageHeight = firstPage.getHeight();

  const qrSize = pageWidth * 0.10;
  const rightMargin = pageWidth * 0.02;
  const topMargin = pageHeight * 0.02;

  const x = Math.max(0, pageWidth - qrSize - rightMargin);
  const y = Math.max(0, pageHeight - qrSize - topMargin);

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
