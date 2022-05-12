---
title: Merge inconsistently named authors in Zotero
date: '2022-05-10'
slug: merge-inconsistently-named-authors-in-zotero
tags:
  - reference management
  - zotero
---

I read several papers written by a same author recently. It is a bit frustrating when I notice the author was inconsistently named in Zotero. For example, the names "Andersen, Bessi Caisa", "Andersen, B. C." and "Andersen, Bessi C." refer to the same author. It would be nice to have these inconsistent names merged. In Endnote, defining term list tells Endnote differently spelt names belonging to the same author. Although being [discussed](https://forums.zotero.org/discussion/74979/merge-inconsistently-named-authors) several years ago, it is still unable to batch edit author names in the current Zotero GUI. 

Zotero has a built-in JavaScript API making batch editing possible. The official documentation provides several examples of batch editing including the following [one that changes author names of multiple items](https://www.zotero.org/support/dev/client_coding/javascript_api#exampleitem_field_changes). 

Back up the library (`zotero.sqlite`) before any operation. Select the `Run JavaScript` in `Tools -> Developer` menu. Copy the script, edit the first four lines as necessary, and hit run. The script worked like a charm. 

``` js
// Edit the first four lines as necessary:
var oldName = "Robert L. Smith";
var newFirstName = "Robert";
var newLastName = "Smith";
var newFieldMode = 0; // 0: two-field, 1: one-field (with empty first name)
 
var s = new Zotero.Search();
s.libraryID = ZoteroPane.getSelectedLibraryID();
s.addCondition('creator', 'is', oldName);
var ids = await s.search();
if (!ids.length) {
    return "No items found";
}
await Zotero.DB.executeTransaction(async function () {
    for (let id of ids) {
        let item = await Zotero.Items.getAsync(id);
        let creators = item.getCreators();
        let newCreators = [];
        for (let creator of creators) {
        	if (`${creator.firstName} ${creator.lastName}`.trim() == oldName) {
        		creator.firstName = newFirstName;
        		creator.lastName = newLastName;
        		creator.fieldMode = newFieldMode;
        	}
        	newCreators.push(creator);
        }
        item.setCreators(newCreators);
        await item.save();
    }
});
return ids.length + " item(s) updated";
```

### Useful links:

* [Zotero JavaScript API](https://www.zotero.org/support/dev/client_coding/javascript_api)
* [Item field editing](https://blog.sciencenet.cn/home.php?mod=space&uid=331295&do=blog&id=1328555)
