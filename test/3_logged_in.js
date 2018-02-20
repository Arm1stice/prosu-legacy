Feature("Site works when logged in");

Scenario('After first login, Tweet posting is disabled', (I) => {
  // Home page
  I.amOnPage("/")
  // Disabled
  I.see("Tweet Posting is Currently Disabled")
  // See enable button
  I.see("ENABLE TWEET POSTING")
});
Scenario("We can enable Tweet posting", (I) => {
  // Home page
  I.amOnPage("/")
  // See button
  I.see("ENABLE TWEET POSTING")
  // Click button
  I.click("#enableButton")
  // Wait
  I.wait(1)
  // See if enabled
  I.see("Tweet Posting is Currently Enabled")
})
