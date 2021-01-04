#Source: Michael Galarnyk - "Accessing Data from Github API using R"
#installing packages
install.packages("jsonlite")
library(jsonlite)

install.packages("httpuv")
library(httpuv)

install.packages("httr")
library(httr)

install.packages("devtools")
require(devtools)

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

#######################################################################################################

userData = fromJSON("https://api.github.com/users/mjrdn")

#number of followers for user defined
userData$followers 

personalFollowers = fromJSON("https://api.github.com/users/mjrdn/followers")

personalFollowers$login

#names of people i'm following
numFollowing = fromJSON("https://api.github.com/users/mjrdn/following")
numFollowing$login 

#number of my repositories that are public
userData$public_repos 

repos = fromJSON("https://api.github.com/users/mjrdn/repos")
#Names of all public repositories
repos$name 
#Date each repository was made
repos$created_at  
#Full names of those repositories
repos$full_name 

#####################################################################################################
#As we can see i'm not a very active user so I will use an example of another classmate who is slightly more active 

userData = fromJSON("https://api.github.com/users/andrewtobin99")

#number of followers for user defined
userData$followers 

personalFollowers = fromJSON("https://api.github.com/users/andrewtobin99/followers")

personalFollowers$login

#names of people i'm following
numFollowing = fromJSON("https://api.github.com/users/andrewtobin99/following")
numFollowing$login 

#number of my repositories that are public
userData$public_repos 

repos = fromJSON("https://api.github.com/users/andrewtobin99/repos")
#Names of all public repositories
repos$name 
#Date each repository was made
repos$created_at  
#Full names of those repositories
repos$full_name 

############################################################################################################################
#Software Engineering Metric Visualisation Project
############################################################################################################################
#I will use data collected from jonathanong (jongleberry) taken from the following link https://gist.github.com/paulmillr/2657075

jonData = GET("https://api.github.com/users/jonathanong/followers?per_page=100;", gtoken)
stop_for_status(jonData)
gitExtract = content(jonData)

#converts into dataframe
githubDB = jsonlite::fromJSON(jsonlite::toJSON(gitExtract))

# Retrieves a list of usernames of followers
githubDB$login

userIDs = githubDB$login
usernames = c(userIDs)

# Creates an empty vector and data.frame
userList = c()
usersDB = data.frame(
  username = integer(),
  following = integer(),
  followers = integer(),
  repositories = integer(),
  dateJoined = integer()
)

#loops through the users extracted and adds them to the list
for(i in 1:length(usernames))
{
  
  followingURL = paste("https://api.github.com/users/", usernames[i], "/following", sep = "")
  followingRequest = GET(followingURL, gtoken)
  followingContent = content(followingRequest)
  
  #Doesn't add users if they aren't following anyone
  if(length(followingContent) == 0)
  {
    next
  }
  
  followingDB = jsonlite::fromJSON(jsonlite::toJSON(followingContent))
  followingLogin = followingDB$login
  
  #Loops through 'following' users
  for (j in 1:length(followingLogin))
  {
    # Check that the user isn't already in the user list 
    if (is.element(followingLogin[j], userList) == FALSE)
    {
      #If user isn't already in list, it adds the user
      userList[length(userList) + 1] = followingLogin[j]
      
      #Retrieves data on each user
      followingURL2 = paste("https://api.github.com/users/", 
                            followingLogin[j], sep = "")
      following2 = GET(followingURL2, gtoken)
      followingContent2 = content(following2)
      followingDB2 = jsonlite::fromJSON(jsonlite::toJSON(followingContent2))
      
      #Gets the users who each user follows
      followingNumber = followingDB2$following
      
      #Gets the followers of each user
      followersNumber = followingDB2$followers
      
      #Gets the number of public repositories each user has
      reposNumber = followingDB2$public_repos
      
      #Gets the year each user joined github
      yearJoined = substr(followingDB2$created_at, start = 1, stop = 4)
      
      #Add users data to a new row in dataframe
      usersDB[nrow(usersDB) + 1, ] = c(followingLogin[j], followingNumber, followersNumber, reposNumber, yearJoined)
      
    }
    next
  }
  #Stops when there is more than 100 users in the list
  if(length(userList) > 100)
  {
    break
  }
  next
}

#Using plotly to graph
install.packages("plotly")
library(plotly)

Sys.setenv("plotly_username"="mjrdn")
Sys.setenv("plotly_api_key"="1xSQT9Yj25CGl2rUEHYP")

#plotting a graph of repositories v followers coloured by year joined
plotReposFollowers = plot_ly(data = usersDB, x = ~repositories, y = ~followers, 
                text = ~paste("Followers: ", followers, "<br>Repositories: ", 
                              repositories, "<br>Date Joined:", dateJoined), color = ~dateJoined)
plotRepFollowers

#sending to plotly
api_create(plotReposFollowers, filename = "Repositories vs Followers")

#plotting a graph of following v followers coloured by year
plotFollowersFollowings = plot_ly(data = usersDB, x = ~following, y = ~followers, text = ~paste("Followers: ", followers, "<br>Following: ", following), color = ~dateJoined)
plotFollowersFollowings

#send to plotly
api_create(plotFollowersFollowings, filename = "Following vs Followers")

#plotting a graph of the 10 most popular languages used by the 100 users.
languages = c()

for (i in 1:length(userList))
{
  reposURL = paste("https://api.github.com/users/", userList[i], "/repos", sep = "")
  repos = GET(reposURL, gtoken)
  reposContent = content(repos)
  reposDB = jsonlite::fromJSON(jsonlite::toJSON(reposContent))
  reposNames = reposDB$name
  
  #Loops through all the repositories of each user
  for (j in 1: length(reposNames))
  {
    #Finds all the repositories and saves in a data frame
    reposURL2 = paste("https://api.github.com/repos/", userList[i], "/", reposNames[j], sep = "")
    repos2 = GET(reposURL2, gtoken)
    reposContent2 = content(repos2)
    reposDB2 = jsonlite::fromJSON(jsonlite::toJSON(reposContent2))
    language = reposDB2$language
    
    #Removes any repositories that contain no specific language
    if (length(language) != 0 && language != "<NA>")
    {
      languages[length(languages)+1] = language
    }
    next
  }
  next
}

#Puts the Ten most popular languages in a table 
eachLanguage = sort(table(languages), increasing=TRUE)
topTenLanguages = eachLanguage[(length(eachLanguage)-9):length(eachLanguage)]

#converts to dataframe
languageDB = as.data.frame(topTenLanguages)

#Plot the data frame of languages
plotTenLanguages = plot_ly(data = languageDB, x = languageDB$languages, y = languageDB$Freq, type = "bar")
plotTenLanguages

Sys.setenv("plotly_username"="mjrdn")
Sys.setenv("plotly_api_key"="1xSQT9Yj25CGl2rUEHYP")
api_create(plotTenLanguages, filename = "Ten Most Popular Languages")

