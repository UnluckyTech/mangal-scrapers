--------------------------------------
-- @name    AsuraScans 
-- @url     https://www.asurascans.com
-- @author  metafates 
-- @license MIT
--------------------------------------




----- IMPORTS -----
Html = require("html")
Headless = require('headless')
Time = require("time")
--- END IMPORTS ---




----- VARIABLES -----
Browser = Headless.browser()
Page = Browser:page()
Base = "https://www.asurascans.com"
Delay = 1 -- seconds
--- END VARIABLES ---



----- MAIN -----

--- Searches for manga with given query.
-- @param query Query to search for
-- @return Table of tables with the following fields: name, url
function SearchManga(query)
    local url = Base .. "/?s=" .. query
    Page:navigate(url)
    Time.sleep(Delay)

    local mangas = {}

    repeat
        for i, v in ipairs(Page:elements(".bsx > a")) do
            local manga = { url = v:attribute('href'), name = v:attribute('title') }
            table.insert(mangas, manga)
        end

        -- Navigate to the next page if available
        local nextPageBtn = Page:element('.pagination .next')
        if nextPageBtn and nextPageBtn:is_enabled() then
            nextPageBtn:click()
            Time.sleep(Delay)
        else
            break  -- Exit the loop if there is no next page
        end
    until false

    return mangas
end


--- Gets the list of all manga chapters.
-- @param mangaURL URL of the manga
-- @return Table of tables with the following fields: name, url
function MangaChapters(mangaURL)
    Page:navigate(mangaURL)
    Time.sleep(Delay)

    local chapters = {}

    for _, v in ipairs(Page:elements("#chapterlist > ul li")) do
        local n = tonumber(v:attribute("data-num"))
        local elem = Html.parse(v:html())
        local link = elem:find("a"):first()

        local chapter = { url = link:attr("href"), name = link:find("span"):first():text() }

        if n ~= nil then
            chapters[n] = chapter
        end
    end

    return chapters
end


--- Gets the list of all pages of a chapter.
-- @param chapterURL URL of the chapter
-- @return Table of tables with the following fields: url, index
function ChapterPages(chapterURL)
    Page:navigate(chapterURL)
    Time.sleep(Delay)

    local pages = {}
    for i, v in ipairs(Page:elements("#readerarea p img")) do
        local p = { index = i, url = v:attribute("src") }
        pages[i + 1] = p
    end

    return pages
end

--- END MAIN ---




----- HELPERS -----
--- END HELPERS ---

-- ex: ts=4 sw=4 et filetype=lua
