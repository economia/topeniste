window.Tooltip = class Tooltip
    (@options = {}) ->
        @options.parent ?= $ 'body'
        @createElement!
        $ document .bind \mousemove @onMouseMove

    watchElements: ->
        $ document .on \mouseover "[data-tooltip]" ({currentTarget}:evt) ~>
            content = $ currentTarget .attr 'data-tooltip'
            content = unescape content
            return if not content.length
            $content = $ "<p></p>"
                ..addClass 'only-child'
                ..html content
            @display $content

        $ document .on \mouseout "[data-tooltip]" @~hide

    display: ($content, mouseEvent) ->
        @$element.empty!
        @$element
            ..append $content
            ..appendTo @options.parent

        @setPosition!

    hide: ->
        @$element.detach!
        @mouseBound = false

    reposition: ([left, top, clientLeft, clientTop]) ->
        dX = left - clientLeft
        dY = top - clientTop
        left += 25
        width = @$element.width!
        height = @$element.height!
        maxLeft = $ window .width! - width - 10
        top -= height / 2
        if left > maxLeft
            left -= width + 50
        if top <= 19 + dY
            top = 19 + dY
        maxTop = $ window .height!
        if top + height > maxTop
            top = maxTop - height
        @$element
            ..css 'left' left
            ..css 'top' top

    createElement: ->
        @$element = $ "<div class='tooltip' />"

    setPosition: ->
        if @options.positionElement
            @setPositionByElement!
        else
            @setPositionByMouse!

    setPositionByElement: ->
        $parent = @options.positionElement
        {left, top} = $parent.offset!
        left += @options.positionElement.width! / 2
        @reposition [left, top]

    setPositionByMouse: ->
        @mouseBound = true
        @reposition @lastMousePosition if @lastMousePosition

    onMouseMove: (evt) ~>
        @lastMousePosition = [evt.pageX, evt.pageY, evt.clientX, evt.clientY]
        if @mouseBound then @reposition @lastMousePosition
