# evil-comment-block
Motions and text objects for comment blocks in
[Evil](https://gitorious.org/evil/), the extensible vi layer for Emacs.

## Setup
### Installing from MELPA
If you already use MELPA, all you have to do is:

    M-x package-install RET evil-comment-block RET

For help installing and using MELPA, see [these instructions](
melpa.milkbox.net/#/getting-started).

### Installing from Github
Install `evil-comment-block` manually from Github with:

    git clone https://github.com/muahah/evil-comment-block.git

### Configuration
After installing `evil-comment-block`, add the following to your `.emacs`:
     (add-to-list 'load-path "path/to/evil-comment-block")
     (require 'evil-comment-block)

     ;; bind evil-comment-block text objects
     (define-key evil-inner-text-objects-map "cb" 'evil-comment-block-inner-block)
     (define-key evil-outer-text-objects-map "cb" 'evil-comment-block-outer-block)

     ;; bind evil-comment-block-comment-or-uncomment-block
     (evil-leader/set-key "cb" 'evil-comment-block-comment-or-uncomment-block)