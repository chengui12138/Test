;; publish.el --- Publish org-mode project on Gitlab Pages
;; Author: Rasmus

(add-to-list 'load-path "/usr/share/emacs/site-lisp")

(defun get-latest-org ()
  "Download the latest Org if the shipped version is too old."
  (let* ((default-directory "/tmp/")
         (org-dir "/tmp/org-mode/")
         (dev-url "https://code.orgmode.org/bzg/org-mode/archive/master.tar.gz")
         (htmlize-url "https://raw.githubusercontent.com/hniksic/emacs-htmlize/master/htmlize.el")
         (devp (zerop (shell-command (concat "wget -q --spider " dev-url)))))
    (unless (file-directory-p org-dir)
      (url-copy-file
       (if devp dev-url "https://orgmode.org/org-latest.tar.gz")
       "org.tar.gz" t)
      (shell-command "tar xfz org.tar.gz;"))
    (unless (file-exists-p (concat org-dir "lisp/org-loaddefs.el"))
      (shell-command (concat (concat "cd " org-dir ";")
                             "make autoloads")))
    (unless (featurep 'htmlize)
      (url-copy-file htmlize-url (concat org-dir "lisp/htmlize.el") t))
    (add-to-list 'load-path (concat org-dir "lisp/"))
    (add-to-list 'load-path (concat org-dir "contrib/lisp/"))))

;; If you need the latest version of Org run this command
(get-latest-org)

;; You can also install Org via package.el.

;; (setq package-selected-packages '(org))
;; (package-initialize)
;; (package-install-selected-packages)

(require 'org)
(require 'ox-publish)

;; Disable time-stamps
;; (setq org-publish-use-timestamps-flag nil)

(setq user-full-name "Rasmus")
(setq user-mail-address "gitlab-pages@pank.eu")

(setq org-export-with-section-numbers nil
      org-export-with-smart-quotes t
      org-export-with-toc nil)

(setq org-html-divs '((preamble "header" "top")
                      (content "main" "content")
                      (postamble "footer" "postamble"))
      org-html-container-element "section"
      org-html-metadata-timestamp-format "%Y-%m-%d"
      org-html-checkbox-type 'html
      org-html-html5-fancy t
      org-html-doctype "html5")

(defvar site-attachments (regexp-opt '("jpg" "jpeg" "gif" "png" "svg"
                                       "ico" "cur" "css" "js" "woff" "html" "pdf")))

(setq org-publish-project-alist
      (list
       (list "site-org"
             :base-directory "."
             :base-extension "org"
             :recursive t
             :publishing-function '(org-html-publish-to-html)
             :publishing-directory "./public"
             :exclude (regexp-opt '("README" "draft"))
             :auto-sitemap t
             :sitemap-filename "index.org"
             :sitemap-file-entry-format "%d *%t*"
             :html-head-extra "<link rel=\"icon\" type=\"image/x-icon\" href=\"/favicon.ico\"/>"
             :sitemap-style 'list
             :sitemap-sort-files 'anti-chronologically)
       (list "site-static"
             :base-directory "."
             :exclude "public/"
             :base-extension site-attachments
             :publishing-directory "./public"
             :publishing-function 'org-publish-attachment
             :recursive t)
       (list "site" :components '("site-org"))))
