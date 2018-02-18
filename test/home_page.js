
Feature('Home Page (not logged in)');

Scenario('Home page works properly when logged out', (I) => {
  // Opens home page
  I.amOnPage('/')
  // Checks to see if page title is correct
  I.seeTitleEquals("Prosu")
  // Make sure that we see the top header on the page
  I.see("Get get your change in ranking and stats posted to your Twitter account every day!")
  // Make sure that there are only 0 users in database and that 0 tweets have been posted
  I.see("Join 0 other users today!")
  I.see("0 tweets posted so far!")
  end()
});
