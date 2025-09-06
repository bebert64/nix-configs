# Update scrappers

```bash
cd programs/configs/stash
rm -rf scrapers
curl -L https://api.github.com/repos/stashapp/CommunityScrapers/tarball | tar -xz --wildcards --strip-components=1 '*/scrapers'
```
