package biz.cunning.cunning_document_scanner.fallback.models


//javadoc:Point_
class Point @JvmOverloads constructor(x: Double = 0.0, y: Double = 0.0) {
    var x = 0.0
    var y = 0.0

    init {
        this.x = x
        this.y = y
    }

    fun set(vals: DoubleArray?) {
        if (vals != null) {
            x = if (vals.size > 0) vals[0] else 0.0
            y = if (vals.size > 1) vals[1] else 0.0
        } else {
            x = 0.0
            y = 0.0
        }
    }


    override fun hashCode(): Int {
        val prime = 31
        var result = 1
        var temp: Long
        temp = java.lang.Double.doubleToLongBits(x)
        result = prime * result + (temp xor (temp ushr 32)).toInt()
        temp = java.lang.Double.doubleToLongBits(y)
        result = prime * result + (temp xor (temp ushr 32)).toInt()
        return result
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Point) return false
        val it = other
        return x == it.x && y == it.y
    }

    override fun toString(): String {
        return "{$x, $y}"
    }
}