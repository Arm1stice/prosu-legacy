Feature("You can log in on the site");

Scenario("Navbar link takes you to login page", (I) => {
  // Opens home page
  I.amOnPage('/')
  // Check value of navbar link text
  I.seeTextEquals("Sign in with Twitter", "//body/nav/div/div/ul/li/a[@href='/connect/twitter']")
  // Click navbar link
  I.click("//body/nav/div/div/ul/li/a[@href='/connect/twitter']")
  // Wait
  I.wait(2);
  I.seeInCurrentUrl("api.twitter.com")
})
Scenario('Home page button takes you to login page', (I) => {
  // Opens home page
  I.amOnPage('/')
  // We see login button
  I.seeTextEquals("SIGN IN WITH TWITTER", "button.btn")
  // Click login button
  I.click("//body/center/a")
  // Wait
  I.wait(2);
  I.seeInCurrentUrl("api.twitter.com")
});
Scenario('We can log in via Twitter', (I) => {
  // Home page
  I.amOnPage('/')
  // Click login button
  I.click("//body/center/a")
  // Wait
  I.wait(2)
  // Check if we are on Twitter login website
  I.seeInCurrentUrl("api.twitter.com");
  // Fill username/password field
  I.fillField("#username_or_email", process.env.TWITTER_USERNAME)
  I.fillField("#password", process.env.TWITTER_PASSWORD)
  // Click login
  I.click("Sign In")
  // wait
  I.waitInUrl('127.0.0.1', 3)
})
