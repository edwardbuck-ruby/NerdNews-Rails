# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  # $("#story_tag_names").tokenInput '/tags.json'
  #   theme: 'facebook'
  #   prePopulate: $("#story_tag_names").data('load')
  #   hintText: "کلمه مورد نظر را جستجو کنید"
  #   noResultsText: "یافت نشد"
  #   searchingText: "در حال جستجو..."

  if $('#tags-list').next('.pagination').length
    $(window).scroll ->
      url = $('.pagination a[rel="next"]').attr('href')
      if url && $(window).scrollTop() > $(document).height() - $(window).height() - 50
        $('.pagination').text("در حال دریافت تگ‌های بیشتر...")
        $.getScript(url)
    $(window).scroll()

  # Used in stories/_form
  $("#story_tag_names").select2({
    multiple: true
    minimumInputLength: 1
    tokenSeparators: [",", " ", "،"]
    dropdownCssClass: "bigdrop"
    ajax:
      url: "/tags.json"
      dataType: 'json'
      data: (term, page)->
          tag_search: term
          page: 1

      results: (tags, page)->
        results: tags

    id: (tags)->
      tags.name

    formatResult: (tags) ->
      tags.name

    formatSelection: (tags) ->
      tags.name

    initSelection: (element, callback)->
      elementText = $(element).data('tags')
      callback(elementText)

    # creates tags if not exist
    createSearchChoice: (term, data) ->
      {id: term, name: term}

    # Translations
    formatNoMatches: (term)->
      'موردی پیدا نشد'
    formatSearching: ->
      'درحال جستجو'
    formatInputTooShort: (term, minLength)->
      minLength + " حرف دیگر وارد کنید"
    })

  $("#tag_search").select2({
    minimumInputLength: 1
    ajax:
      url: "/tags.json"
      dataType: 'json'
      data: (term, page)->
          tag_search: term
          page: 1

      results: (tags, page)->
        results: tags

    formatResult: (tags) ->
      tags.name

    formatSelection: (tags) ->
      tags.name

    dropdownCssClass: "bigdrop"

    # Translations
    formatNoMatches: (term)->
      'موردی پیدا نشد'
    formatSearching: ->
      'درحال جستجو'
    formatInputTooShort: (term, minLength)->
      minLength + " حرف دیگر وارد کنید"
  })

  $("#tag_search").on("change", (e)->
    $('.form-search').submit()
    )
