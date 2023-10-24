UPDATE
	scenes
SET
	title = new_names.value
FROM (
	SELECT
		SUBSTRING(files.basename, 1, LENGTH(files.basename) - 4) AS value,
		scenes_inner.id AS scene_id
	FROM
		files
		INNER JOIN scenes_files ON files.id = scenes_files.file_id
		INNER JOIN scenes AS scenes_inner ON scenes_files.scene_id = scenes_inner.id
		INNER JOIN scenes_tags ON scenes_inner.id = scenes_tags.scene_id
		INNER JOIN tags ON scenes_tags.tag_id = tags.id
	WHERE
		title IS NULL
		AND tags.name = "OK") AS new_names
WHERE
	scenes.id = new_names.scene_id;
