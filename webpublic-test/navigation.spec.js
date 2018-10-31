// / <reference types="Cypress" />


describe('OpenBank Public Website', () => {
  before(() => {
    cy.visit('https://www.openbank.es');
    cy.clearCookies();
  });
  context('Check links', () => {
    it('Cookies Banner', () => {
      cy.get('#cookies-policy');
    });

    it('Productos', () => {
      cy.get('nav').contains('Productos').click();

      cy.get('nav').contains('Cuentas').click();
      cy.get('nav').contains('Cuentas para tus gestiones');
      cy.get('nav').contains('Cuentas de Ahorro');

      cy.get('nav').contains('Tarjetas').click();
      cy.get('nav').contains('Tarjetas de Débito y Crédito');

      cy.get('nav').contains('Financiación').click();
      cy.get('nav').contains('Hipotecas Open');
      cy.get('nav').contains('Préstamos y Créditos');

      cy.get('nav').contains('Depósitos').click();
      cy.get('nav').contains('Depósito Open 13 meses');

      cy.get('nav').contains('Openbank Wealth').click();
      cy.get('nav').contains('Invertimos por ti');
      cy.get('nav').contains('Tú inviertes');
      cy.get('nav').contains('Herramientas de Inversión');
    });

    it('Promociones y descuentos', () => {
      cy.get('nav').contains('Promociones y descuentos').click();

      cy.get('nav').contains('Promociones');
      cy.get('nav').contains('Descuentos Open');
    });

    it('Quienes somos', () => {
      cy.get('nav').contains('Quiénes somos');
    });

    it('Ayuda Urgente', () => {
      cy.get('header').contains('Ayuda Urgente').click();
      cy.location('pathname').should('include', 'ayuda-urgente');
      cy.go('back');
    });

    it('Contactanos', () => {
      cy.get('header').contains('Contáctanos').click();
      cy.location('pathname').should('include', 'contacto');
      cy.go('back');
    });

    it('Preguntas frecuentes', () => {
      cy.get('header').contains('Preguntas Frecuentes').click();
      cy.location('pathname').should('include', 'ayuda/no-cliente');
      cy.go('back');
    });
  });
});

Cypress.on('uncaught:exception', (err, runnable) => {
  console.log(err);
  return false;
});
