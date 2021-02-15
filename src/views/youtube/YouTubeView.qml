import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

import ".."

import org.maui.clip 1.0 as Clip

BrowserLayout
{
    id: youtubeViewRoot


    Connections
    {
        target: Clip.YouTube
        onQueryResultsReady:
        {
            searchRes = res;
            populate(searchRes)
            youtubeTable.forceActiveFocus()

            if(openVideo > 0)
            {
                console.log("trying to open video")
                watchVideo(youtubeTable.model.get(openVideo-1))
                openVideo = 0
            }
        }
    }

    model.list: Clip.YouTubeModel
    {

    }


    function watchVideo(track)
    {
        if(track && track.url)
        {
            var url = track.url
            if(url && url.length > 0)
            {
                youtubeViewer.currentYt = track
                youtubeViewer.webView.url = url+"?autoplay=1"
                stackView.push(youtubeViewer)

            }
        }
    }

    function playTrack(url)
    {
        if(url && url.length > 0)
        {
            var newURL = url.replace("embed/", "watch?v=")
            console.log(newURL)
            webView.url = newURL+"?autoplay=1+&vq=tiny"
            webView.runJavaScript("document.title", function(result) { console.log(result); });
        }
    }

    function runSearch(searchTxt)
    {
        if(searchTxt)
            if(searchTxt !== youtubeTable.title)
            {
                youtubeTable.title = searchTxt
                Vvave.YouTube.getQuery(searchTxt, Maui.FM.loadSettings("YOUTUBELIMIT", "BABE", 25))
            }
    }

    function clearSearch()
    {
        searchInput.clear()
        youtubeTable.listView.model.clear()
        youtubeTable.title = ""
        searchRes = []
    }

    function populate(tracks)
    {
        youtubeTable.model.clear()
        for(var i in tracks)
            youtubeTable.model.append(tracks[i])
    }
}
