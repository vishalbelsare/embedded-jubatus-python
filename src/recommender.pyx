from _wrapper cimport _Recommender

from jubatus.recommender.types import IdWithScore

cdef class _RecommenderWrapper:
    cdef _Recommender *_handle

    def __cinit__(self):
        self._handle = NULL

    def __dealloc__(self):
        if self._handle != NULL:
            del self._handle

    def _init(self, config):
        self._handle = new _Recommender(config)
        typ, ver = b'recommender', 1
        return (
            lambda: self._handle.get_config().decode('utf8'),
            lambda: self._handle.dump(typ, ver),
            lambda x: self._handle.load(x, typ, ver),
            lambda: self._handle.clear(),
        )

    def clear_row(self, id_):
        self._handle.clear_row(id_.encode('utf8'))
        return True

    def update_row(self, id_, row):
        cdef datum d
        datum_py2native(row, d)
        self._handle.update_row(id_.encode('utf8'), d)
        return True

    def complete_row_from_id(self, id_):
        cdef datum d = self._handle.complete_row_from_id(id_.encode('utf8'))
        return datum_native2py(d)

    def complete_row_from_datum(self, row):
        cdef datum d0
        datum_py2native(row, d0)
        cdef datum d1 = self._handle.complete_row_from_datum(d0)
        return datum_native2py(d1)

    def similar_row_from_id(self, id_, size):
        cdef vector[pair[string, float]] ret
        ret = self._handle.similar_row_from_id(id_.encode('utf8'), size)
        return [
            IdWithScore(ret[i].first.decode('utf8'), ret[i].second)
            for i in range(ret.size())
        ]

    def similar_row_from_datum(self, row, size):
        cdef vector[pair[string, float]] ret
        cdef datum d
        datum_py2native(row, d)
        ret = self._handle.similar_row_from_datum(d, size)
        return [
            IdWithScore(ret[i].first.decode('utf8'), ret[i].second)
            for i in range(ret.size())
        ]

    def decode_row(self, id_):
        cdef datum d = self._handle.decode_row(id_.encode('utf8'))
        return datum_native2py(d)

    def get_all_rows(self):
        cdef vector[string] ret = self._handle.get_all_rows()
        return [(<string>ret[i]).decode('utf8') for i in range(ret.size())]

    def calc_similarity(self, l, r):
        cdef datum d0
        cdef datum d1
        datum_py2native(l, d0)
        datum_py2native(r, d1)
        return self._handle.calc_similarity(d0, d1)

    def calc_l2norm(self, row):
        cdef datum d
        datum_py2native(row, d)
        return self._handle.calc_l2norm(d)
