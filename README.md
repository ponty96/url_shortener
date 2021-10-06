# UrlShortener

## How to run the app
Follow the guideline in the Makefile.

## Design

### Data storage
I used two different tables, one for storing the short links while the other, a counter for the hit link metric.

- short_urls
user_id
slug
long_url
timestamps

index on the slug
Compound index on user_id and long_url

create index short_urls_user_id_long_url_index
create index short_urls_slug_index


- Link hits
user_id - we added this field to fetch total link hits metrics for a specific user_id
slug
hits
create index link_hits_user_id_index


I decided to use two tables to separate concerns and reduce writes/read request latency as our data grows due to usage.

Lookup on insertion

Our hash algorithm might generate the same hashes for different long urls. To ensure uniqueness, we will add unique indexes on the slug. The database will bubble an error up, when we attempt to insert duplicate slugs.

We will add a compound index on user_id ad long_url, we want to prevent duplication of the same long url by the same user.

Thankfully, Ecto gracefully bubbles up index conflict as changeset errors.


### Github
Used Github Actions as our simple CI setup to run the Elixir and Cypress tests for our API and UI respectively.


### Valid URL
We will use the OWASP regex for a valid url found here -> https://owasp.org/www-community/OWASP_Validation_Regex_Repository


### Link Shortening

We will generate a slug, check if the slug exists in our db, and retry five times to generate a unique slug.


* Lookup a short url, to get the long url and redirect
    * Speed for this, we need to consider using an index here or maybe use redis as the database
* Increment the counter -> this should be an async task to not block this process
* Redirect to the long url



### Ramblings

I thought to share my thought process.

SCHEMA LEVEL

Context ->

Shortener Storage
* insert
1- Does it insert the data when an existing short url is not found? -> {:ok, short_slug}
Validate that we logged info here

2- Does it return an {:ok, short_slug}, when a short url is found with the same long url
Validate that we logged info here

3- Does it return an {:error, :existing} when a short url is found with a different long url
Validate that we logged warn here, and counter for how often our algorithm is a hit miss

* Find short url
1- return {:ok, long_url} when the short_url is found
       * have a Appsignal counter for a successful lookup
	validate that it makes an async call to link hit counter
2- return {:errror, resource not found} when the short url is not found
Log a warning here and also add like a counter to see how people fake our system

* Record link hit
1- Validate that it increases the counter when its called -> use a different table for this to reduce latency on the current table for the short urls


LinkShortener service
* Shorten link - unit function
1- validates that it shortens a link when its passed to it. {:ok shortened}
2- it returns an error when the text passed is not a link


* Shortener - side effect function
1- Validates that it shortens and inserts a data when an existing short url is not found
Validate that we logged info here

2- Validates that it shortens but does not add a new record when an existing short url with the same long url is found
Validate that we logged info here

3- How do we validate that we make multiple attempts until we have a short url that does not exist in our system?
Validate that we logged warn here, and counter for how often our algorithm is a hit miss

4- Validate that it rejects invalid urls



* Parse text
    * It extracts all the links in a tex, makes an async call to the shortener code to shorted the links
    * This should call the shortened link command
        * This should also handle the insertion
1- validates that the texts are replaced in the order that they are passed
2- validates that the links are shortened
3- Validate that it rejects invalid urls


* Lookup
   1- Validate that when we find a matching short url we increase the hit link metric
    2- Validate that when we don’t find a matching short url, we don’t hit the link metric


Controller

* Short url
-> Params Schema
	validate that it rejects invalid urls - ALSO BE DONE ON THE REACT APP
	validate that it rejects an empty string - ALSO BE DONE ON THE REACT APP


-> When passed valid params, we return a valid shortened url to the user
-> When passed invalid paras, we return a good error message to the user


* /{slug}
-> validate that when its a known slug, we redirect to the long url and increase link hit
-> validate that when its an unknown slug, we redirect to a 404 page

