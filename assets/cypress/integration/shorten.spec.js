import React from 'react';
import { ENDPOINTS } from "../../js/constants"
import Faker from "faker"
import { v4 } from 'uuid';

describe('Shortener', () => {
  it('renders the right page with the expected input and buttons', () => {
    cy.server()

    cy.visit('/')
    cy.get('p').contains('Enter a long URL to make a LittleURL');


    cy.get('section').within(() => {
      cy.get('input[name="url"]').should('exist') // Only yield inputs within form
      cy.get('input[type="submit"]').should('have.value', 'Make LittleURL!') // Only yield textareas within form
    })
  });

  it('it makes an API call when the user attempts to submit with a valid URL, and renders the success page', () => {
    cy.server()

    cy.visit('/')
    cy.get('p').contains('Enter a long URL to make a LittleURL');


    cy.get('section').within(() => {
      cy.get('input[name="url"]').should('exist') // Only yield inputs within form
      cy.get('input[type="submit"]').should('have.value', 'Make LittleURL!') // Only yield textareas within form
    })

    cy.route('POST', ENDPOINTS.SHORT_URL).as('request')

    const URL_INPUT = Faker.internet.url()

    cy.get('input[name="url"]').type(URL_INPUT)

    cy.get('input[type="submit"]').should('have.value', 'Make LittleURL!').click()

    // it shows the success layout
    cy.get('p').contains('Your Long URL')
    cy.get('p').contains('LittleURL')

    cy.get('input[name="longUrl"]').should('exist')
    cy.get('input[name="shortUrl"]').should('exist')

    cy.get('button').contains('Shorten another')

    cy
      .get('a')
      .contains('Visit URL')
      .then(link => {
        cy.request(link.prop('href'))
          .its('status')
          .should('eq', 301)
      })

    cy.get('button').contains('Copy').click()
  });

  it('the success page buttons work as expected', () => {
    cy.server()

    cy.visit('/')
    cy.get('p').contains('Enter a long URL to make a LittleURL');


    cy.get('section').within(() => {
      cy.get('input[name="url"]').should('exist') // Only yield inputs within form
      cy.get('input[type="submit"]').should('have.value', 'Make LittleURL!') // Only yield textareas within form
    })

    // Stub the request
    const URL_INPUT = Faker.internet.url()

    const expectedShortenUrl = "https://localhost:4000/dioeHDue"

    cy.intercept('POST', ENDPOINTS.SHORT_URL, {
      statusCode: 201,
      body: {
        data: {
          url: expectedShortenUrl
        }
      },
    })


    cy.get('input[type="url"]').type(URL_INPUT)

    cy.get('input[type="submit"]').should('have.value', 'Make LittleURL!').click()


    // it shows the success layout
    cy.get('p').contains('Your Long URL')
    cy.get('p').contains('LittleURL')

    cy.get('input[name="longUrl"]').should('exist').should('have.value', URL_INPUT)
    cy.get('input[name="shortUrl"]').should('exist').should('have.value', expectedShortenUrl)

    cy
      .get('a')
      .contains('Visit URL')
      .should('have.attr', 'href', expectedShortenUrl)
      .should('have.attr', 'target', '_blank')


    cy.get('button').contains('Copy').click().should(() => {
      cy.task('getClipboard').should('eq', expectedShortenUrl)
    })

    cy.get('button').contains('Shorten another').click()

    // Validate that we are back to the first page
    cy.get('p').contains('Enter a long URL to make a LittleURL');


    cy.get('section').within(() => {
      cy.get('input[name="url"]').should('exist') // Only yield inputs within form
      cy.get('input[type="submit"]').should('have.value', 'Make LittleURL!') // Only yield textareas within form
    })
  });
})

