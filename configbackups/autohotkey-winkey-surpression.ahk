; =============================================
; DEFINITELY SUPPRESS — these will conflict with Emacs
; =============================================

#L::Return          ; Lock screen
#D::Return          ; Show/hide desktop
#Tab::Return        ; Task view
#C::Return          ; Copilot
#S::Return          ; Windows Search
#Q::Return          ; Search (alt)
#A::Return          ; Action center / Quick settings
#N::Return          ; Notification center
#W::Return          ; Widgets
#Z::Return          ; Snap layout
#Space::Return      ; Switch input language
#,::Return          ; Peek at desktop
#.::Return          ; Emoji picker
#/::Return          ; Input method shortcut
#+S::Return         ; Screenshot snip
#+C::Return         ; Color picker
#+Left::Return      ; Snap window left
#+Right::Return     ; Snap window right
#+Up::Return        ; Maximize window
#+Down::Return      ; Minimize/restore window
#^Left::Return      ; Move to left monitor
#^Right::Return     ; Move to right monitor
#^Up::Return        ; Move to top monitor  
#^Down::Return      ; Move to bottom monitor
#Home::Return       ; Minimize all but active
#M::Return          ; Minimize all windows
#+M::Return         ; Restore minimized windows

; =============================================
; PROBABLY SUPPRESS — situationally useful but
; you likely handle these inside Emacs
; =============================================

#E::Return          ; File Explorer
#R::Return          ; Run dialog
#T::Return          ; Cycle taskbar apps
#B::Return          ; Focus taskbar
#K::Return          ; Connect to display/cast
#P::Return          ; Project/display mode
#X::Return          ; Quick link menu
#V::Return          ; Clipboard history
#H::Return          ; Voice typing
#F::Return          ; Feedback hub
#G::Return          ; Xbox game bar
#I::Return          ; Settings
#U::Return          ; Accessibility settings
#+V::Return         ; Clipboard history (alt)
#+F::Return         ; Feedback
#+H::Return         ; Share content

; Number keys — taskbar app switching
#1::Return
#2::Return
#3::Return
#4::Return
#5::Return
#6::Return
#7::Return
#8::Return
#9::Return
#0::Return

; =============================================
; CONSIDER KEEPING — genuinely useful at OS level
; =============================================

; #L — lock screen (security, might want to keep)
; #+L — same
; #PrtScn — screenshot to file (useful)
; #+PrtScn — screenshot region
; #Pause — system properties
; #^Q — quick assist