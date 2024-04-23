Hello! If you’re just looking for the roadmap, scroll down. Otherwise, if you’re interested in contributing to the project read on for the guidelines.

## Want to Contribute?
Please fork the develop branch and submit a Pull Request when you have code to review. It’s worth reaching out to me first (see link below) before starting on a feature to make sure we’re aligned. At this time all features will need to go through GitHub for code review. I can’t accept copy/pasted or zipped code at this time. Depending on what is submitted, it is possible that your code may not make it back into the project, but we’ll do our best to avoid that together. If you want to get in touch to discuss what you have in mind first, please find me on [Discord](https://discord.gg/JVxRsbCvdb) (You’ll find me as the Admin Sean)

## Project Goals
While I’m more than grateful for anyone’s interest in contributing to this project, I am keeping an eye on the scope of this project and the pace at which it grows. Leading up to v1.0, I aim to keep this code as accessible and new-developer friendly as possible. That might mean leaving even optional intermediate+ modules for later in the roadmap. And to that end, here is the roadmap as it stands today:

## Feature Roadmap
Because I’m hoping to release regular updates that have a mix of small, medium, and larger features, some low priority features (ex: QOL stuff) might make it into the next build even though they’re not super critical - which is why I’m grouping these by proximity to release rather than priority.

If you want to work on something that’s not on this list, that might be fine too. This list is very fluid. Please reach out Discord at the link above and let me know what you’d like to add. This is preferable to having a Pull Request just show up on my doorstep, though I do appreciate your zeal :P 

### Soon-ish
- Screen resolution / fullscreen settings (done, in develop branch)
- Confirm dialog / modal template - throw up a window with some options and listen for user input (confirm/cancel/etc)
- Stock level select template
- Input remapping for system
- Some global input listening (ex: hitting ESC anywhere enters a pause menu or closes and existing modal)
- Support for multiple save slots (with UI for naming, creating, and deleting saves)
- Settings: option to restore defaults

### Later
- Stock player controller templates
- Resource-based save system
- AudioManager
- Further abstraction of SceneManager (largely decoupling loading graphic from SceneManager and likely cleaning up the way transitions are authored)
- Steam API wrapper
- Accessibility options in the Settings menu template

### Future
- State Machine module
- Localization helper class
- Dialog system (would integrate with loc helper class)
- Adding support to existing scenes for mobile layouts
- Build templates
- Documentation outside of gdscript files
- HUD class to more easily build common things like health bars, score display

A huge thanks to [Fritzy](https://github.com/fritzy) for contributing to the project and helping me understand best practices for managing an open source project. I’d also like to thank Braydee of [GameDev Artisan](https://gamedevartisan.com/) for helping out with this repo.

I’m still learning how to do this properly. I appreciate you. -Sean
