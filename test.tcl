#  Slurp up the data file
set fp [open "Input.txt"]
set file_data [read $fp]
close $fp
set lines [split $file_data "\n"]
foreach line $lines {
    puts "$line"
    set words [split $line " "]
    foreach it $words {
        puts "$it"
    }
}

proc SplitIntoWords {block} {
    set words {}
    set word ""

    while {[string length $block]} {
        # Look for the next group of whitespace characters.
        if {[regexp -indices "\[ \t\n\]+" $block all]} {
            # Remove the text leading up to and including the white space
            # from the block.
            set text [string range $block 0 [lindex $all 1]]
            set block [string range $block [expr {[lindex $all 1] + 1}] end]
        } else {
            # Take everything up to the end of the block.
            set text $block
            set block {}
        }

        # Add the text to the end of the word we are building up.
        append word $text

        if { [catch {llength $word} length] == 0 && $length == 1} {
            # The word is a valid list so add it to the list.
            lappend words [string trim $word]
            set word {}
        }
    }

    # If the last word has not been added to the list then there
    # is a problem.
    if { [string length $word] } {
        error "incomplete word \"$word\""
    }

    return $words
}