# AmazonMySizeDeals
Go from current item to relevant items to relevant items of relevant items and so on and so forth and show only good deals

# Mechanism
When you run into an enticing product, say, a pair of brand A shoes of size 10, this tool will leverage Amazon's recommendation carosell that show several panels of related products to expand your choices, and will repeat this process recursively for the expanded circle of products to further expand the selection, to form a kind of a web of products that has the initially viewed item at the center. Then, a simple process will query the prices of all the relevant items, and filter them down to only the size you wear, and finally only show the items priced below a ceiling of your choice.
