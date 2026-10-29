;; wip-site-template: simple website for pages under construction or maintenance
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (maak)
  #:declarative? #t
  #:use-module (maak maak)
  #:export (default deploy link undeploy serve))

;; ====== Maak constants ======

;; The site is these two files. Nothing to build, nothing to compile.
(define site-files '("index.html" "index.css"))

;; The checkout this Maak file lives in, so the tasks work from anywhere.
(define project-root
  (let ((file (current-filename)))
    (if file
        (dirname file)
        (getcwd))))

;; Where the site is published when WIP_SITE_DEPLOY_DIR is not set.
(define default-deploy-dir
  "/srv/http/wip-site.jointhefreeworld.org")

;; ====== Helpers ======

(define (deploy-dir)
  "Return the publish directory: $WIP_SITE_DEPLOY_DIR, or the default."
  (let ((from-env (getenv "WIP_SITE_DEPLOY_DIR")))
    (if (and from-env (> (string-length from-env) 0))
        from-env
        default-deploy-dir)))

(define (site-file file)
  "Return the absolute path of FILE in this checkout."
  (string-append project-root "/" file))

(define (deployed-file file)
  "Return the absolute path FILE takes in the deploy directory."
  (string-append (deploy-dir) "/" file))

(define (ensure-deploy-dir)
  "Create the deploy directory when it is missing, and say where it is."
  (unless (file-exists? (deploy-dir))
    (log-info "Creating deploy directory ~a\n" (deploy-dir)))
  (mkdir-p (deploy-dir))
  (log-info "Deploying to ~a\n" (deploy-dir)))

(define (require-site-files)
  "Fail early, before touching the server, when a source file is missing."
  (for-each (lambda (file)
              (unless (file-exists? (site-file file))
                (raise-maak-error (~ "missing source file: ~a" (site-file file))
                                  #:hint
                                  "index.html and index.css belong at the repository root.")))
            site-files))

;; ====== Maak tasks ======

(define (default)
  "Default task, list the available tasks.

Run `maak' with no arguments, or `maak --list', to see every task."
  ($ '("maak --list")))

(define (deploy)
  "Copy index.html and index.css into the deploy directory.

The publish directory is $WIP_SITE_DEPLOY_DIR when it is set, and
/srv/http/wip-site.jointhefreeworld.org otherwise.  There is no build step:
the files are the site.

Examples:
  maak deploy
  WIP_SITE_DEPLOY_DIR=/var/www/example.org maak deploy"
  (require-site-files)
  (ensure-deploy-dir)
  (for-each (lambda (file)
              (cp (site-file file) (deployed-file file) #:force? #t))
            site-files))

(define (link)
  "Publish by symlinking index.html and index.css into the deploy directory.

Editing a file in this checkout updates the live page on the next request: no
copy, no deploy step, no stale file on the server.  Handy during an incident,
when the wording of the maintenance page changes every few minutes.

The links are absolute, so re-run `maak link' after moving the repository.

Examples:
  maak link
  WIP_SITE_DEPLOY_DIR=/var/www/maintenance maak link"
  (require-site-files)
  (ensure-deploy-dir)
  (for-each (lambda (file)
              (ln-s (site-file file) (deployed-file file)))
            site-files))

(define (undeploy)
  "Remove the published index.html and index.css from the deploy directory.

Only the two files this project manages are removed; the directory itself and
anything else living in it are left untouched."
  (log-info "Removing the published site from ~a\n" (deploy-dir))
  (for-each (lambda (file)
              (run (list "rm" "-fv" (deployed-file file))))
            site-files))

(define (serve)
  "Serve the site on http://127.0.0.1:8080 for a local look.

Uses Python's built-in HTTP server, so there is nothing to install and no
dev-server configuration to maintain.  Stop it with Ctrl-C."
  (require-command "python3"
                   #:hint "Install Python 3, or just open index.html in a browser.")
  (log-info "Serving ~a on http://127.0.0.1:8080\n" project-root)
  (with-directory project-root
    (lambda ()
      ($ (list "python3 -m http.server 8080 --bind 127.0.0.1")))))
