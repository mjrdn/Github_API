#Source: Michael Galarnyk - "Accessing Data from Github API using R"
#installing packages
install.packages("jsonlite")
library(jsonlite)

install.packages("httpuv")
library(httpuv)

install.packages("httr")
library(httr)

oauth_endpoints("github")

#My OAuth application settings
myapp <- oauth_app(appname = "Access_Github_SWENG",
                   key = "ed10ac61b18ea38fe312",
                   secret = "e6798afab384e5a81170bbdf256ce1f5d6f7fa55")

# Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)

# Use API
gtoken <- config(token = github_token)
req <- GET("https://api.github.com/users/jtleek/repos", gtoken)

# Take action on http error
stop_for_status(req)

# Extract content from a request
json1 = content(req)

# Convert to a data.frame
gitDF = jsonlite::fromJSON(jsonlite::toJSON(json1))

# Subset data.frame
gitDF[gitDF$full_name == "jtleek/datasharing", "created_at"] 
