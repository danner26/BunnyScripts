# BunnyScripts

`BunnyScripts` is a repo dedicated to Bash Bunny scripting that uses standalone payloads, and payloads that reply on the [BunnyAPI](https://github.com/danner26/BunnyAPI) repo by Daniel W. Anner and Gregory Walsh. This project is originally for our CSIS33-3381 with Dr. Aakash Taneja. In working on this project, we have found a new respect and passion for these Bash Bunny scripts. We plan to keep our research going, and continue to upkeep and integrate new features for this repo.

## Usage
When using this repo's payloads, you are free to adapt it for your needs, but any scripts relying on the API will work best with the tested latest tested master version over at the [BunnyAPI](https://github.com/danner26/BunnyAPI) repo. After following the [wiki setup](https://github.com/danner26/BunnyScripts/wiki/Setup), you are set to use the payloads!

### Current API locations
| BunnyScript       | API Base (Port+Path) | Individual API Path | Full API Path                                      |
| ----------------- | -------------------- | ------------------- | -------------------------------------------------- |
| ChromeCreds       | 4001 + /chrome       | /submitChromeCreds  | http(s)://domain.tld:4001/chrome/submitChromeCreds |

## License
`BunnyScripts` is licensed under the GNU GENERAL PUBLIC LICENSE v3.0. (https://opensource.org/licenses/GPL-3.0)

## Code of Conduct
This project and everyone participating in it is governed by the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [daniel.anner@danstechsupport.com](mailto:daniel.anner@danstechsupport.com).

## Contributing
Pull requests are the way to go here. We only have two rules for submitting a pull request: match the naming convention (camelCase) and any other styling set hereon. 
