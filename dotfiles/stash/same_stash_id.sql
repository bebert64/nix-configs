SELECT
	ssi.stash_id AS discriminant,
	sc.title
FROM
	scenes sc
	JOIN scene_stash_ids ssi ON sc.id = ssi.scene_id
GROUP BY
	ssi.stash_id
HAVING
	COUNT(*) > 1
UNION
SELECT
	su.url AS discriminant,
	sc.title
FROM
	scenes sc
	JOIN scene_urls su ON sc.id = su.scene_id
WHERE
	NOT (su.url = 'NO URL')
GROUP BY
	su.url
HAVING
	COUNT(*) > 1;
