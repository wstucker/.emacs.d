;;; Helper for managing XFCE window manager
;;
;; My workflow is to keep one emacs session per workspace and generally have
;; 5-10 workspaces active. I try to rename the workspace with a brief note
;; about what I'm working on in that area.

(defun xfce-workspace-get-current-number ()
  (string-to-number
   (replace-regexp-in-string "\n\\'" ""
                             (shell-command-to-string "wmctrl -d | grep '*' | cut -d \" \" -f1"))))

(defun xfce-workspace-get-all-names ()
  (split-string
   (replace-regexp-in-string "\n\\'" ""
                             (shell-command-to-string
                              (format "xfconf-query -c xfwm4 -p /general/workspace_names | tail -n +3")))
   "[\n]+"))

(defun xfce-workspace-get-current-name ()
  (let ((workspace-num (xfce-get-current-workspace-number))
         (workspace-names (xfce-workspace-get-all-names)))
    (nth workspace-num workspace-names)))

(defun xfce-workspace-set-current-name (NEW-NAME)
  "Set the workspace name in the XFCE window manager."
  (interactive
   (list
    (completing-read "Set workspace name: " '() nil nil (xfce-get-current-workspace-name))))
  (let ((all-workspaces (xfce-workspace-get-all-names))
        (workspace-num (xfce-workspace-get-current-number)))
    (setcar (nthcdr workspace-num all-workspaces) NEW-NAME)
    (let ((new-names (mapconcat (lambda (x) "" (format "-s \"%s\"" x)) all-workspaces " ")))
      (shell-command-to-string (concat "xfconf-query -c xfwm4 -p /general/workspace_names " new-names)))))
