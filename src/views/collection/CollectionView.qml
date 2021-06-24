import org.maui.clip 1.0 as Clip

import ".."

BrowserLayout
{
    id: control

    list.urls: Clip.Clip.sources

    onItemClicked:
    {
        play(item)
    }    
}
