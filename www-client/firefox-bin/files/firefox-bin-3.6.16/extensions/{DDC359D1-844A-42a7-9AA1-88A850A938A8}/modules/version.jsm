const EXPORTED_SYMBOLS = ['ID', 'ITEM', 'VERSION', 'BASE_VERSION', 'NAME', 'compareVersion'];

const ID = '{DDC359D1-844A-42a7-9AA1-88A850A938A8}';
const ITEM = Components.classes["@mozilla.org/extensions/manager;1"]
	.getService(Components.interfaces.nsIExtensionManager)
	.getItemForID(ID);

const VERSION = ITEM.version;
const BASE_VERSION = VERSION.replace(/^([\d\w]+\.[\d\w]+).*?$/, '$1');
const NAME = ITEM.name;

const comparator = 
	Components.classes['@mozilla.org/xpcom/version-comparator;1']
	.getService(Components.interfaces.nsIVersionComparator);

function compareVersion(version, cmp) {
	if (!cmp) {
		[version, cmp] = [VERSION, version];
	}
	return comparator.compare(version, cmp);
}