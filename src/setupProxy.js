const { createProxyMiddleware } = require('http-proxy-middleware');

const apiUrl = process.env.REACT_APP_BACKEND_BASE_URL;

module.exports = function(app) {
    app.use(
        '/api',
        createProxyMiddleware({
            target: apiUrl,
            changeOrigin: true,
            pathRewrite: {
                '^/api': '', // remove `/api` from the beginning of the path
            }
        })
    );
};
