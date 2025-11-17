const request = require('supertest');
const app = require('./app');

describe('API Hello World', () => {
  describe('GET /', () => {
    it('deve retornar status 200', async () => {
      const response = await request(app).get('/');
      expect(response.status).toBe(200);
    });

    it('deve retornar "Hello World" no body', async () => {
      const response = await request(app).get('/');
      expect(response.body).toEqual({ message: 'Hello World' });
    });

    it('deve retornar JSON como Content-Type', async () => {
      const response = await request(app).get('/');
      expect(response.headers['content-type']).toMatch(/json/);
    });
  });

  describe('GET /health', () => {
    it('deve retornar status OK', async () => {
      const response = await request(app).get('/health');
      expect(response.status).toBe(200);
      expect(response.body).toEqual({ status: 'OK' });
    });
  });
});

