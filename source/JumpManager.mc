import Toybox.Lang;

module JumpManager {
    // Licznik wyskoków
    public var jumpCount as Number = 0;

    // Metoda do inkrementacji (możesz ją wywoływać po wykryciu wyskoku)
    function addJump() as Void {
        jumpCount++;
    }

    // Resetowanie licznika (np. przy starcie nowej sesji)
    function reset() as Void {
        jumpCount = 0;
    }
}