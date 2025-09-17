;; wip-site-template: simple website for pages under construction or maintenance

;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; wip-site-template is free software: you can redistribute it and/or modify
;; it under the terms of the GNU Affero General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; wip-site-template is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU Affero General Public License for more details.

;; You should have received a copy of the GNU Affero General Public License
;; along with wip-site-template.  If not, see <https://www.gnu.org/licenses/>.


(define-module (maak)
  #:declarative? #t
  #:use-module (maak maak))

;; ====== Maak constants ======

;; The absolute path to the directory where the main project files will be deployed.
(define deploy-dir
  "/srv/http/wip-site.jointhefreeworld.org")

;; ====== Maak tasks ======

(define (default)
  "Default task to be run, list available tasks."
  ($ '("maak --list")))

(define (deploy)
  "Deploy the project."
  (delete-file-recursively (~ "~a/index.html" deploy-dir))
  (mkdir-p (~ "~a" deploy-dir))
  ($ (list "cp -rfv index.html" (~ "~a/" deploy-dir)))
  ($ (list "cp -rfv index.css" (~ "~a/" deploy-dir))))
