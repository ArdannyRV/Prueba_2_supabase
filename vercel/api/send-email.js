const nodemailer = require('nodemailer');

export default async function handler(req, res) {
  // Configurar cabeceras CORS
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  );

  // Manejar las peticiones preflight (OPTIONS) para CORS
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  // Acepte solo peticiones POST.
  if (req.method !== 'POST') {
    return res.status(405).json({ success: false, error: 'Method Not Allowed' });
  }

  // Extraiga to, subject y text de req.body.
  const { to, subject, text } = req.body;

  if (!to || !subject || !text) {
    return res.status(400).json({ success: false, error: 'Faltan campos requeridos: to, subject, text' });
  }

  try {
    // Cree un transporter de Nodemailer
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });

    // Envíe el correo configurando el campo from
    await transporter.sendMail({
      from: '"Proyecto Elecciones" <' + process.env.EMAIL_USER + '>',
      to: to,
      subject: subject,
      text: text,
    });

    // Retorne un JSON con { success: true } si funciona
    return res.status(200).json({ success: true });
  } catch (error) {
    console.error('Error enviando el correo:', error);
    // status 500 con el error si falla.
    return res.status(500).json({ success: false, error: error.message || 'Error al enviar el correo' });
  }
}
