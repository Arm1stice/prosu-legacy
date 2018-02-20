
Feature('Site functions when not logged in');

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
  // Make sure we see that there is a button to log in
  I.seeTextEquals("SIGN IN WITH TWITTER", "button.btn")
  I.seeTextEquals("Sign in with Twitter", "//body/nav/div/div/ul/li/a")
  // Make sure we see the link for the Privacy Policy
  I.see("Privacy Policy")
});

Scenario('Privacy policy can be accessed', (I) => {
  // Home page
  I.amOnPage('/')
  // See link
  I.see("Privacy Policy")
  // Click privacy policy
  I.click("Privacy Policy")
  // Wait for URL change
  I.seeInCurrentUrl("/privacy")
  // Make sure page is correct
  I.see("Privacy Policy")
  I.see("When you login to Prosu using your Twitter account")
})
