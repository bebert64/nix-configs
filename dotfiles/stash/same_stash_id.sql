SELECT
	ssi.stash_id,
	sc.title
FROM
	scenes sc
	JOIN scene_stash_ids ssi ON sc.id = ssi.scene_id
GROUP BY
	ssi.stash_id
HAVING
	COUNT(*) > 1;
