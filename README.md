# hubspot-backup

Ruby scripts to backup Hubspot content to files

These are very rough and simple scripts which you can use to backup your Hubspot content on drive.

Currently you can export blogposts, landing and website pages, templates and custom modules. They are saved in the same location where the script is. Each piece of content is saved as JSON file containing 1:1 API response from Hubspot.

## Usage

Each script backups different parts of content. They need Hubspot API Key to work. `HAPIKEY` will be read from the first script argument or `HAPIKEY` environmental variable. So, for example if hapikey=demo:

```
ruby backup_blogposts.rb demo
```

or if `ENV['HAPIKEY']` is set:

```
ruby backup_blogposts.rb
```

---

**These scripts are not yet finished and tested. They work, but you should treat them as drafts.**
