#!/usr/bin/env python3

import iterm2
import sys

async def main(connection):
    profile_name  = sys.argv[1]
    all_profiles = await iterm2.PartialProfile.async_query(connection)

    if  profile_name ==  "--list":
        for  profile in  all_profiles:
            print(profile.name)
        return

    for profile in all_profiles:
        if profile.name == profile_name:
            await profile.async_make_default()
            full = await profile.async_get_full_profile()
            app = await iterm2.async_get_app(connection)
            await app.current_terminal_window.current_tab.current_session.async_set_profile(full)
            return

    print("No profile found with name: " + profile_name)

    for  profile in  all_profiles:
        print(profile.name)

    sys.exit(1)






iterm2.run_until_complete(main)
